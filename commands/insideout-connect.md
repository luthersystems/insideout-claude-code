---
description: Switch the InsideOut MCP server URL (local dev, prod, or custom)
argument-hint: <local|prod|URL>
allowed-tools: [Read, Write, Bash]
---

# InsideOut Connect — Switch MCP Server

Switch which MCP server the InsideOut plugin connects to. Useful for local development against the MCP server.

## Arguments

The user invoked this command with: $ARGUMENTS

## Presets

| Preset | URL |
|--------|-----|
| `local` | `http://localhost:8080/mcp` |
| `prod` | Removes override, falls back to default `.mcp.json` (production) |

Any other argument is treated as a custom URL.

## Instructions

1. Determine the target from `$ARGUMENTS`:
   - If `local` → URL is `http://localhost:8080/mcp`
   - If `prod` → delete `.mcp.local.json` if it exists, then tell the user to restart Claude Code
   - If it looks like a URL (starts with `http://` or `https://`) → use it directly
   - If empty or missing → show usage help and stop

2. For `local` or custom URL: find the plugin install directory. Use Glob to search for the InsideOut plugin's `.mcp.json`:
   - First try: `~/.claude/plugins/insideout-claude-code/.mcp.json`
   - Fallback: search `~/.claude/plugins/**/.mcp.json` and find the one containing `insideout-mcp`

   The `.mcp.local.json` file goes in the **same directory** as the plugin's `.mcp.json`.

   Write this content to `.mcp.local.json`:
   ```json
   {
     "mcpServers": {
       "insideout": {
         "type": "http",
         "url": "<TARGET_URL>"
       }
     }
   }
   ```

3. For `prod`: delete `.mcp.local.json` if it exists. If it doesn't exist, tell the user they're already on prod.

4. After writing or deleting, tell the user:
   - Which server they're now pointing to
   - **They must restart Claude Code** (`/exit` then re-launch) for the change to take effect, since MCP server connections are established at startup
