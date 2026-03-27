---
description: Start an InsideOut infrastructure design session with Riley
argument-hint: [description of what you want to build]
allowed-tools: [Read, Glob, Grep, Bash, mcp__insideout__convoopen, mcp__insideout__convoreply, mcp__insideout__convoawait, mcp__insideout__convostatus, mcp__insideout__help]
---

# InsideOut Infrastructure Design

You are starting an InsideOut infrastructure design session. Follow these steps precisely:

## Step 1: Build Project Context

Before calling any InsideOut tools, put together a short project context summary for Riley (the infrastructure advisor). Base this on what you already know about the user's project -- from the working directory, recent conversation, or what they've told you.

**Include whichever of these apply:**

| Detail | Why Riley needs it | Example |
|---|---|---|
| Language and framework | Determines compute type (Lambda vs ECS vs EC2), runtime constraints | "Node.js 20, Next.js 15" |
| Database and services | Shapes data tier and caching recommendations | "PostgreSQL, Redis" |
| Container usage | Informs orchestration choice (ECS, EKS, Cloud Run) | "Docker Compose, 3 services" |
| Existing infrastructure-as-code | Avoids conflicting with what's already provisioned | "Terraform with ECS + RDS" |
| CI/CD platform | Integrates deployment pipeline | "GitHub Actions" |
| Cloud provider | Targets the right provider from the start | "AWS" or "GCP" |
| Kubernetes usage | Determines whether to target existing K8s or provision new compute | "EKS with Helm" |
| What the project does | General understanding for architecture fit | "E-commerce API, ~50k MAU" |

**NEVER include:**
- **Credentials or secrets** -- No API keys, tokens, passwords, private keys, or `.env` values
- **PII** -- No usernames, emails, or personally identifiable information
- **Source code** -- Only metadata summaries, never file contents
- **Internal URLs or IPs** -- Omit specific internal hostnames, IPs, or endpoint URLs

**Format:**

```
IDE: Claude Code
Language/Runtime: <if known>
Framework: <if known>
Databases/Services: <if known>
Target Cloud: <if known>
Infrastructure: <if known>
CI/CD: <if known>
```

Only include lines where you have information. Keep it general and anonymized.

**Before sending**, show the summary to the user and confirm: "I'd like to share this project summary with Riley so it can tailor its recommendations -- does this look right?" If they decline or want to edit it, respect that. If you don't have enough context, skip `project_context` entirely -- Riley will ask discovery questions instead.

## Step 2: Start the Session

Call `convoopen` with:
- `project_context`: The summary you confirmed with the user (omit if skipped). Must not contain credentials, secrets, PII, source code, or internal URLs.
- `source`: `"claude-code"`

If the user provided arguments with the `/insideout` command, also call `convoreply` immediately after `convoopen` with the user's description as the message.

## Step 3: Display Riley's Response

**OUTPUT RILEY'S MESSAGE VERBATIM.** Copy the exact text from the tool response and display it as your entire reply. Do not add anything before it, after it, or around it. No introduction ("Here's what Riley said"), no summary, no commentary, no "Go ahead and..." prompts. Riley's words ARE your response. The user should see Riley's message and nothing else.

## Ongoing Conversation Rules

After the session is open, follow these rules for every subsequent user message:

1. **Always call a tool** — never just say "Understood" or "Got it" without a tool call
2. **Route to `convoreply`** by default — when in doubt, send the user's message to Riley
3. **Don't answer Riley's questions** — forward them to the user for their input
4. **Display Riley's responses verbatim** — no preamble, no commentary, no wrapper text. Riley's message is your entire output.
5. **Watch for phase transitions:**
   - `[TERRAFORM_READY: true]` in response metadata means call `tfgenerate`
   - After `tfgenerate`, offer to deploy with `tfdeploy`
   - Monitor deployments with `tfstatus` and `tflogs`
   - After deployment, verify with `awsinspect` or `gcpinspect`

## User Arguments

The user invoked this command with: $ARGUMENTS

If arguments were provided, use them as the initial description of what they want to build.
