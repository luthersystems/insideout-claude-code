# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InsideOut for Claude Code is a **Claude Code plugin** — an agentic cloud infrastructure builder and manager. Users describe their goal in natural language and Riley guides them through requirements, cost estimation, Terraform generation, deployment, and ongoing production management on AWS and GCP.

This is a **thin MCP client** — there is no compiled source code, build system, or backend. All logic runs on the hosted InsideOut MCP server. The plugin consists entirely of Markdown files (skill definitions, commands, steering guides) and JSON configuration.

## Architecture

**Multi-Agent System:** The MCP server orchestrates specialized agents behind a single conversational interface:
- **Riley** — Infrastructure advisor (user-facing)
- **Hippo** — Cost estimation
- **Joy** — UX/requirement gathering
- **Etch** — Terraform code generation
- **Core** — Architecture validation
- **Axel** — Deployment orchestration

**Conversation Flow:** Design → Configuration → Pricing → Terraform Generation → Deployment → Inspection

**Workspace Context Scanning:** Before starting a session, the `/insideout` command scans the user's workspace to detect language/runtime, frameworks, existing infrastructure (Terraform, Docker, K8s), CI/CD platform, and cloud provider signals.

## Repository Structure

```
.claude-plugin/     Plugin metadata (plugin.json, marketplace.json)
.mcp.json           MCP server connection config (prod endpoint)
commands/           Slash command definitions (/insideout:start, /insideout:connect)
skills/insideout/   SKILL.md — activation triggers, tool catalog, conversation flow rules
steering/           User-facing guides (getting-started, design patterns, troubleshooting)
assets/             SVG banner and logo
```

## Key Files

- `skills/insideout/SKILL.md` — Core file: defines activation triggers, all MCP tools, and conversation flow rules
- `commands/start.md` — The `/insideout:start` slash command implementation with workspace scanning logic
- `commands/connect.md` — The `/insideout:connect` command for switching MCP server URL
- `.mcp.json` — MCP server URL (https://app.luthersystems.com/v1/insideout-mcp)
- `steering/aws-design-patterns.md` / `gcp-design-patterns.md` — Pre-built infrastructure patterns

## Development

All changes are Markdown or JSON edits. No compilation or dependencies.

**Test locally:**
```
claude --plugin-dir ./
```

Then run `/insideout:start` to test the plugin end-to-end.

**MCP Tools (21):** Conversation (`convoopen`, `convoreply`, `convoawait`, `convostatus`), Terraform (`tfgenerate`, `tfplan`, `tfdeploy`, `tfdestroy`, `tfdrift`), Monitoring (`tfstatus`, `tflogs`, `tfoutputs`, `tfruns`), Stack Management (`stackversions`, `stackdiff`, `stackrollback`), Cloud Inspection (`awsinspect`, `gcpinspect`), Credentials (`credawait`), Meta (`submit_feedback`, `help`).
