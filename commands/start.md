---
description: Start an InsideOut infrastructure design session with Riley
argument-hint: [description of what you want to build]
allowed-tools: [Read, Glob, Grep, Bash, mcp__insideout__convoopen, mcp__insideout__convoreply, mcp__insideout__convoawait, mcp__insideout__convostatus, mcp__insideout__help]
---

# InsideOut Infrastructure Design

You are starting an InsideOut infrastructure design session. Follow these steps precisely:

## Step 1: Scan Workspace for Project Context

Before calling any InsideOut tools, silently scan the user's workspace to build a `project_context` string. This gives Riley (the infrastructure advisor) immediate context about the user's tech stack.

**Scan these files/patterns** (check existence, extract key fields only):

| File / Pattern | What to extract |
|---|---|
| `package.json` | Runtime, framework, key deps (pg, redis, prisma, aws-sdk, etc.) |
| `requirements.txt`, `pyproject.toml`, `Pipfile` | Python version, framework, key deps |
| `go.mod` | Go version, key deps (gin, echo, pgx, go-redis) |
| `Cargo.toml` | Rust edition, key deps |
| `pom.xml`, `build.gradle` | Java/Kotlin framework, key deps |
| `Gemfile` | Ruby version, framework, key deps |
| `Dockerfile`, `docker-compose.yml` | Container usage, service images, exposed ports |
| `*.tf`, `terraform/` | Existing IaC provider and resource types |
| `serverless.yml` | Serverless Framework, provider |
| `.github/workflows/`, `.gitlab-ci.yml` | CI/CD platform |
| `k8s/`, `kubernetes/`, `helm/` | Kubernetes usage, chart dependencies |
| `README.md` | Project description (first ~30 lines) |
| `.env`, `.env.example` | Environment variable names (NOT values) — database URLs, API keys, service names |
| `Makefile` | Build targets, deployment commands |
| `Procfile`, `app.yaml` | Platform deployment targets |

**Cloud provider detection** — look for signals:

| Signal | Indicates |
|---|---|
| `*.tf` with `provider "aws"` or `aws_*` resources | AWS |
| `*.tf` with `provider "google"` or `google_*` resources | GCP |
| `aws-sdk`, `@aws-sdk/*`, `boto3`, `aws-cdk-lib` in deps | AWS |
| `@google-cloud/*`, `google-cloud-*` in deps | GCP |
| CI/CD with `aws-actions/*`, `configure-aws-credentials` | AWS |
| CI/CD with `google-github-actions/*`, `workload_identity_provider` | GCP |

**Architecture detection** — look for patterns:

| Pattern | What it tells Riley |
|---|---|
| Multiple `Dockerfile`s or `docker-compose.yml` services | Microservices architecture |
| Single `Dockerfile` | Monolithic or simple service |
| `k8s/` manifests | Already using Kubernetes |
| API route files (`routes/`, `controllers/`, `handlers/`) | API service — count endpoints |
| Database migration files (`migrations/`, `alembic/`) | Database schema complexity |
| Queue/worker files (`workers/`, `jobs/`, `tasks/`) | Async processing needs |
| WebSocket or real-time code | Real-time infrastructure needs |

**Format the context string:**

```
IDE: Claude Code
Language/Runtime: <detected>
Framework: <detected>
Databases/Services: <detected from deps and config>
Target Cloud: <detected with evidence>
Infrastructure: <existing IaC, containers, k8s>
CI/CD: <detected>
Architecture: <monolith/microservices/serverless, number of services>
Scale Indicators: <any traffic/user numbers from README or config>
```

Only include lines where something was detected. Always include the IDE line.

## Step 2: Start the Session

Call `convoopen` with:
- `project_context`: The context string you built above
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
