.PHONY: demo demo-record demo-gif demo-preview test

# Record a real InsideOut session and generate demo GIF (automated via tmux)
demo: demo-record demo-gif

# Record session: launches Claude Code in tmux, drives conversation automatically
demo-record:
	./assets/record-demo.sh --record

# Convert saved .cast recording to animated GIF
demo-gif:
	./assets/record-demo.sh --gif

# Preview the demo GIF in the default browser
demo-preview:
	open -a "Brave Browser" assets/demo.gif 2>/dev/null || open -a Safari assets/demo.gif 2>/dev/null || open assets/demo.gif

# Test plugin locally
test:
	claude --plugin-dir ./
