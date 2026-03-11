#!/usr/bin/env bash
# record-demo.sh — Record a real InsideOut session for the demo GIF
#
# Launches Claude Code inside a tmux session with asciinema recording.
# Runs from the demo/ directory to avoid MCP server conflicts with the
# plugin's .mcp.json in the repo root.
#
# Usage:
#   make demo-record   # Start recording (drives conversation via tmux)
#   make demo-gif      # Convert recording to GIF
#   make demo          # Both steps
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - asciinema installed (brew install asciinema)
#   - agg installed (brew install agg)
#   - tmux installed (brew install tmux)
#   - InsideOut plugin installed

set -euo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel)"
DEMO_DIR="$REPO_ROOT/demo"
CAST_FILE="$REPO_ROOT/.tmp/demo.cast"
GIF_OUTPUT="$REPO_ROOT/assets/demo.gif"
PLUGIN_DIR="$REPO_ROOT"
TMUX_SESSION="insideout-demo"

mkdir -p "$REPO_ROOT/.tmp"

# ─── Helper: wait for text on tmux pane ───
wait_for() {
  local pattern="$1"
  local timeout="${2:-60}"
  local elapsed=0
  while ! tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null | grep -q "$pattern"; do
    sleep 2
    elapsed=$((elapsed + 2))
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "⚠ Timeout waiting for: $pattern"
      return 1
    fi
  done
  return 0
}

# Auto-approve any permission dialogs that appear
approve_dialogs() {
  local screen
  screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
  if echo "$screen" | grep -q "Do you want to proceed"; then
    tmux send-keys -t "$TMUX_SESSION" "y" Enter
    sleep 2
    return 0
  fi
  if echo "$screen" | grep -q "Allow\|Yes\|Approve"; then
    if echo "$screen" | grep -q "Enter to confirm"; then
      tmux send-keys -t "$TMUX_SESSION" Enter
      sleep 2
      return 0
    fi
  fi
  return 1
}

# Wait for Claude Code to return to the input prompt (done thinking)
# Two-phase detection: first ensure Claude starts working, then wait for idle prompt
wait_for_prompt() {
  local timeout="${1:-90}"
  local elapsed=0

  # Phase 1: Wait for Claude to start processing (spinner, thinking, tool call)
  echo "    (waiting for processing to start...)"
  sleep 3
  elapsed=3
  local started=false
  while [ "$elapsed" -lt 30 ]; do
    local screen
    screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
    if echo "$screen" | grep -qE "⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏|◐|◑|◒|◓|Thinking|thinking|Running|Lollygagging|Tool use|⎿"; then
      started=true
      break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  if [ "$started" = false ]; then
    echo "    (no processing detected, checking if already done...)"
  fi

  # Phase 2: Wait for Claude to finish — require two consecutive idle checks
  # to avoid false positives from screen refresh gaps
  echo "    (waiting for response to complete...)"
  local idle_count=0
  while [ "$elapsed" -lt "$timeout" ]; do
    # Auto-approve any permission dialogs
    approve_dialogs 2>/dev/null || true

    local screen
    screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
    local is_idle=false
    # Status bar with context % means Claude Code UI is loaded
    if echo "$screen" | grep -q "ctx:"; then
      # Not in a dialog
      if ! echo "$screen" | grep -q "Enter to confirm"; then
        # Not in a permission prompt
        if ! echo "$screen" | grep -q "Do you want to proceed"; then
          # No active spinners or processing indicators
          if ! echo "$screen" | grep -qE "⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏|◐|◑|◒|◓|\(thinking\)|Running|queued|Press up to edit"; then
            is_idle=true
          fi
        fi
      fi
    fi

    if [ "$is_idle" = true ]; then
      idle_count=$((idle_count + 1))
      if [ "$idle_count" -ge 3 ]; then
        sleep 3  # Final buffer
        return 0
      fi
    else
      idle_count=0
    fi
    sleep 5
    elapsed=$((elapsed + 5))
  done
  echo "⚠ Timeout waiting for prompt ($timeout s)"
  return 1
}

# ─── Step 1: Record session ───

run_record() {
  # Kill any existing session
  tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

  echo "▶ Starting Claude Code recording session..."
  echo "  Recording to: $CAST_FILE"
  echo ""

  # Create a temp directory OUTSIDE the git repo to avoid .mcp.json conflicts
  # (Claude Code resolves project root to git root, which loads .mcp.json)
  local WORK_DIR
  WORK_DIR=$(mktemp -d /tmp/insideout-demo.XXXXXX)
  mkdir -p "$WORK_DIR/.claude"
  cp "$DEMO_DIR/.claude/settings.json" "$WORK_DIR/.claude/settings.json"
  echo "  Working directory: $WORK_DIR"

  # Launch tmux → asciinema → claude from the temp directory
  tmux new-session -d -s "$TMUX_SESSION" -x 100 -y 30 -c "$WORK_DIR" \
    "unset CLAUDECODE && stty cols 100 rows 30 2>/dev/null; asciinema rec '$CAST_FILE' --cols 100 --rows 30 --overwrite --command 'claude --plugin-dir $PLUGIN_DIR --model sonnet'"
  # Resize the tmux window to enforce dimensions
  tmux resize-window -t "$TMUX_SESSION" -x 100 -y 30 2>/dev/null || true

  # Handle startup dialogs
  sleep 3

  # Trust dialog
  if tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null | grep -q "trust this folder"; then
    echo "  Accepting trust dialog..."
    tmux send-keys -t "$TMUX_SESSION" Enter
    sleep 3
  fi

  # MCP server approval dialog
  if tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null | grep -q "New MCP server"; then
    echo "  Approving MCP server..."
    tmux send-keys -t "$TMUX_SESSION" Enter
    sleep 5
  fi

  # Wait for Claude Code input prompt (the actual input line, not menu selector)
  echo "  Waiting for Claude Code to start..."
  local tries=0
  while [ "$tries" -lt 30 ]; do
    local screen
    screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
    # Check for the input prompt: a line starting with ❯ followed by a space and cursor
    # but NOT a menu (which has numbered options below)
    if echo "$screen" | grep -q "Sonnet.*ctx:" ; then
      # Status bar is visible = Claude Code is at the input prompt
      # Make sure no dialog is active
      if ! echo "$screen" | grep -q "Enter to confirm"; then
        break
      fi
    fi
    sleep 2
    tries=$((tries + 1))
  done

  if [ "$tries" -ge 30 ]; then
    echo "✗ Claude Code failed to reach input prompt"
    echo "  Current screen:"
    tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null
    tmux kill-session -t "$TMUX_SESSION" 2>/dev/null
    exit 1
  fi

  sleep 2
  echo "  ✓ Claude Code is ready"

  # ─── Conversation: scripted user input, natural Claude/Riley responses ───
  # Each step sends a user message via tmux (appears as typed input at the ❯
  # prompt), then waits for Claude to finish responding before sending the next.

  # Helper: wait for Claude to be idle (not thinking/running/processing)
  # Uses double-check with 15s pause to avoid false positives.
  wait_idle() {
    local max="${1:-300}"
    local elapsed=0
    sleep 5  # Let Claude start processing
    elapsed=5
    while [ "$elapsed" -lt "$max" ]; do
      approve_dialogs 2>/dev/null || true
      local screen
      screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
      if echo "$screen" | grep -q "ctx:"; then
        if ! echo "$screen" | grep -qE "\(thinking\)|Running|queued|Press up to edit|█.*[0-9]+%|processing|tokens\)|⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏|◐|◑|◒|◓"; then
          sleep 15
          screen=$(tmux capture-pane -t "$TMUX_SESSION" -p 2>/dev/null)
          if echo "$screen" | grep -q "ctx:"; then
            if ! echo "$screen" | grep -qE "\(thinking\)|Running|queued|Press up to edit|█.*[0-9]+%|processing|tokens\)|⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏|◐|◑|◒|◓"; then
              return 0
            fi
          fi
        fi
      fi
      sleep 10
      elapsed=$((elapsed + 10))
    done
    echo "  ⚠ Timeout after ${max}s"
    return 1
  }

  # Step 1: Start InsideOut session
  echo ""
  echo "  Step 1: /insideout:start"
  tmux send-keys -t "$TMUX_SESSION" "/insideout:start" Enter
  wait_idle 180
  echo "  ✓ Riley responded"

  # Step 2: Describe the app (appears as typed user input)
  echo ""
  echo "  Step 2: Describe app"
  tmux send-keys -t "$TMUX_SESSION" "I'm building a serverless video streaming platform on AWS with GitHub Actions for CI/CD." Enter
  wait_idle 300
  echo "  ✓ Riley responded with recommendations"

  # Step 3: Accept and ask for pricing
  echo ""
  echo "  Step 3: Accept config, request pricing"
  tmux send-keys -t "$TMUX_SESSION" "Looks great, proceed to pricing." Enter
  wait_idle 300
  echo "  ✓ Pricing received"

  # Step 4: Generate Terraform
  echo ""
  echo "  Step 4: Generate Terraform"
  tmux send-keys -t "$TMUX_SESSION" "Generate the Terraform." Enter
  wait_idle 300
  echo "  ✓ Terraform generated"

  # Exit Claude Code
  echo ""
  echo "  Exiting Claude Code..."
  tmux send-keys -t "$TMUX_SESSION" "/exit" Enter
  sleep 5

  # Wait for tmux session to end
  local exit_timeout=15
  while tmux has-session -t "$TMUX_SESSION" 2>/dev/null && [ "$exit_timeout" -gt 0 ]; do
    sleep 1
    exit_timeout=$((exit_timeout - 1))
  done
  tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

  if [ -s "$CAST_FILE" ]; then
    echo ""
    echo "✓ Recording saved to $CAST_FILE"
    echo "  Size: $(du -h "$CAST_FILE" | cut -f1)"
    echo "  Preview: asciinema play $CAST_FILE"
  else
    echo "✗ Recording failed — no output"
    exit 1
  fi
}

# ─── Step 2: Convert to GIF ───

generate_gif() {
  if [ ! -s "$CAST_FILE" ]; then
    echo "✗ No recording at $CAST_FILE. Run 'make demo-record' first."
    exit 1
  fi

  echo "▶ Generating GIF with agg..."

  agg \
    --font-family "Iosevka Nerd Font Mono,JetBrainsMono Nerd Font" \
    --font-size 14 \
    --theme dracula \
    --speed 2 \
    --last-frame-duration 4 \
    --idle-time-limit 5 \
    "$CAST_FILE" \
    "$GIF_OUTPUT"

  size=$(du -h "$GIF_OUTPUT" | cut -f1)
  echo "✓ GIF saved to $GIF_OUTPUT ($size)"
}

# ─── Main ───

case "${1:-all}" in
  --record)
    run_record
    ;;
  --gif)
    generate_gif
    ;;
  all|*)
    run_record
    generate_gif
    ;;
esac
