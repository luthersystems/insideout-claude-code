---
name: insideout
description: >
  Use when the user mentions infrastructure, cloud, AWS, GCP, Terraform, deployment, DevOps,
  containers, Kubernetes, serverless, VPC, networking, databases, load balancers, CDN, monitoring,
  or asks to "design infrastructure", "set up cloud", "deploy my app", "estimate cloud costs",
  "generate terraform", "inspect my deployment", "what would this cost on AWS/GCP",
  or discusses scaling, high availability, disaster recovery, or compliance requirements
  for cloud infrastructure.
version: 1.0.0
---

# InsideOut -- Agentic Infrastructure Builder & Manager

InsideOut is an agentic cloud infrastructure builder and manager by Luther Systems. Describe your goal, discuss requirements, estimate cost, generate Terraform, deploy, operate and manage in production. Riley -- your AI infrastructure advisor -- guides you through the entire lifecycle on AWS and GCP.

**No authentication or API keys required.** The plugin connects to a hosted MCP server.

## When This Skill Activates

Use InsideOut when the user's request involves:
- Designing cloud infrastructure (AWS or GCP)
- Estimating cloud costs
- Generating Terraform code
- Deploying infrastructure
- Inspecting deployed cloud resources
- Comparing AWS vs GCP options
- Infrastructure planning for their application

## Available MCP Tools

### Design Conversation
- **`convoopen`** -- Start a new session. Pass `source: "claude-code"` and `project_context` (see below).
- **`convoreply`** -- Send user's message to Riley. Required: `session_id`, `message`.
- **`convoawait`** -- Wait for long-running response. Required: `session_id`.
- **`convostatus`** -- View current stack (components, config, pricing). Required: `session_id`.

### Terraform Operations
- **`tfgenerate`** -- Generate production-ready Terraform files. Required: `session_id`.
- **`tfdeploy`** -- Deploy to AWS or GCP. Required: `session_id`. Takes 15+ minutes.
- **`tfplan`** -- Preview changes without applying. Required: `session_id`.
- **`tfdestroy`** -- Tear down deployed infrastructure. Required: `session_id`.
- **`tfdrift`** -- Detect infrastructure drift. Required: `session_id`.

### Monitoring
- **`tfstatus`** -- Quick deployment status check. Required: `session_id`.
- **`tflogs`** -- Stream deployment logs (paginated). Required: `session_id`.
- **`tfoutputs`** -- Get Terraform outputs (VPC IDs, endpoints, etc.). Required: `session_id`.
- **`tfruns`** -- List all deployment runs for a session. Required: `session_id`.

### Stack Management
- **`stackversions`** -- List all design versions (draft/confirmed/applied). Required: `session_id`.
- **`stackdiff`** -- Compare two stack versions. Required: `session_id`.
- **`stackrollback`** -- Revert to a previous design version. Required: `session_id`.

### Cloud Inspection
- **`awsinspect`** -- Inspect deployed AWS resources. Required: `session_id`.
- **`gcpinspect`** -- Inspect deployed GCP resources. Required: `session_id`.

### Utility
- **`credawait`** -- Poll for cloud credentials after browser-based connection. Required: `session_id`.
- **`submit_feedback`** -- Submit bug reports or feature requests. Required: `session_id`, `category`, `message`.
- **`help`** -- Get workflow guidance and tool documentation.

## Workspace Context Scanning

**Before calling `convoopen`**, scan the user's workspace to build a `project_context` string. Claude Code has deep file access -- use it to give Riley comprehensive context.

### What to Scan

| File / Pattern | Extract |
|---|---|
| `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `Gemfile` | Language, framework, key dependencies |
| `Dockerfile`, `docker-compose.yml` | Container usage, service topology, exposed ports |
| `*.tf`, `terraform/` | Existing IaC, provider, resource types |
| `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` | CI/CD platform and deployment targets |
| `k8s/`, `kubernetes/`, `helm/` | Kubernetes usage |
| `README.md` | Project description (first ~30 lines) |
| `.env.example`, `.env.local` | Environment variable names (NOT values) |
| `Makefile`, `Procfile` | Build and deployment patterns |
| API routes, controllers, handlers | Service count and API surface |
| Database migrations | Schema complexity |
| Queue/worker files | Async processing needs |

### Cloud Provider Detection

| Signal | Provider |
|---|---|
| `provider "aws"` in `.tf`, `aws-sdk`/`boto3` in deps, `aws-actions/*` in CI | AWS |
| `provider "google"` in `.tf`, `@google-cloud/*` in deps, `google-github-actions/*` in CI | GCP |

### Format

```
IDE: Claude Code
Language/Runtime: Node.js 20, TypeScript
Framework: Next.js 15
Databases/Services: PostgreSQL (via prisma), Redis (via ioredis)
Target Cloud: AWS (existing Terraform with ECS + RDS resources)
Infrastructure: Docker Compose (3 services), Terraform
CI/CD: GitHub Actions
Architecture: Microservices (3 services detected)
```

Only include lines where something was detected. Always include the IDE line.

## Conversation Flow

### Starting a Session

1. Scan workspace files silently (no output to user)
2. Call `convoopen` with `project_context` and `source: "claude-code"`
3. Display Riley's response **verbatim** -- output the exact text from the tool response as your entire reply. No preamble ("Here's what Riley said"), no summary, no commentary, no "Go ahead and..." wrapper. Riley's words ARE your response.

### During the Conversation

**Every user message must produce a tool call.** Apply this decision tree:

1. Is the user responding to Riley? -> `convoreply`
2. Is the user asking for Terraform? -> `tfgenerate` (if `[TERRAFORM_READY: true]`)
3. Is the user asking to deploy? -> `tfdeploy`
4. Is the user asking for status? -> `convostatus`, `tfstatus`, or `tflogs`
5. Not sure? -> Default to `convoreply`

**Never respond with only "Understood", "Got it", or any acknowledgement without calling a tool.**

### Phase Transitions

| Phase | Signal | Action |
|---|---|---|
| Design | Riley asking questions | Forward to user via `convoreply` |
| Design complete | `[TERRAFORM_READY: true]` | Call `tfgenerate` |
| Terraform generated | Files returned | Show files, offer `tfdeploy` |
| Deploying | Job running | Monitor with `tfstatus` / `tflogs` |
| Deployed | Status complete | Verify with `awsinspect` / `gcpinspect` |

**Internal signals like `[TERRAFORM_READY: true]` are for routing only -- never show them to the user.**

### Deployment Monitoring

Deployments take 15-30 minutes. Use subagents for `tflogs` to avoid flooding the conversation:

1. Call `tfstatus` for a quick pass/fail check (safe inline)
2. Launch a background subagent to poll `tflogs` with `last_event_id` pagination
3. Summarize the outcome when the subagent completes

## Critical Rules

### Do:
- Show Riley's messages verbatim as your entire output -- no preamble, no wrapper, no commentary. You are a transparent relay.
- Use `convostatus` proactively to check progress
- Store the `session_id` from `convoopen` -- all tools need it
- Let users review Terraform before deploying
- Be specific about requirements (traffic, compliance, regions, budget)
- Monitor deployments with `tflogs` (use subagents for long logs)

### Don't:
- Don't answer Riley's questions yourself -- always forward to the user
- Don't add commentary around Riley's messages
- Don't call `convoopen` more than once per session
- Don't call `tfgenerate` before design is complete
- Don't call `tfdeploy` before user reviews Terraform
- Don't fabricate session IDs -- always use the one from `convoopen`

## Steering Files

For detailed guidance on specific workflows, read the steering files in this plugin:

- **Getting started** -> `steering/getting-started.md`
- **AWS design patterns** -> `steering/aws-design-patterns.md`
- **GCP design patterns** -> `steering/gcp-design-patterns.md`
- **Troubleshooting** -> `steering/troubleshooting-guide.md`

## Troubleshooting

### MCP server not connected
The InsideOut MCP server is remote (HTTPS) -- no local binary needed. If tools fail, check that the plugin is enabled in Claude Code settings.

### Session ID errors
Session IDs must start with `sess_v2_`. Always use the ID returned by `convoopen`. Never guess or fabricate IDs.

### Timeouts
Use `convoawait` if `convoreply` times out. Complex designs may take 30-50 seconds to process.

### Deployment takes too long
This is normal. Terraform deployments take 15-30 minutes (EKS clusters alone take 15-20 minutes). Use `tflogs` to monitor progress.

## Support

- **Discord:** https://insideout.luthersystems.com/discord
- **Tech call:** https://insideout.luthersystems.com/tech-call
- **Email:** contact@luthersystems.com
