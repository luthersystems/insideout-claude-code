<p align="center">
  <img src="assets/banner.svg" alt="InsideOut -- Agentic Infrastructure Builder & Manager" width="100%">
</p>

<p align="center">
  <strong>Agentic cloud infrastructure builder & manager -- describe your goal, discuss requirements, estimate cost, generate Terraform, deploy, operate and manage in production</strong>
</p>

<p align="center">
  <a href="https://insideout.luthersystems.com">InsideOut</a> &bull;
  <a href="https://luthersystems.com">Luther Systems</a> &bull;
  <a href="https://insideout.luthersystems.com/discord"><img src="https://img.shields.io/badge/Discord-Join%20Us-5865F2?logo=discord&logoColor=white" alt="Discord"></a>
</p>

---

## What is InsideOut?

InsideOut is a [Claude Code](https://claude.ai/code) plugin that brings agentic cloud infrastructure management directly into your terminal. Describe your goal in plain language, and Riley -- your AI infrastructure advisor -- guides you through requirements, service selection, cost estimation, Terraform generation, deployment, and ongoing production management on AWS or GCP.

**No authentication or API keys required.** Install the plugin and start building.

### What You Can Do

- **Describe your goal** -- tell Riley what you're building, get expert infrastructure recommendations
- **Discuss requirements** -- refine architecture, regions, compliance, scaling needs interactively
- **Estimate cost** -- see real-time monthly cost estimates as components are added
- **Generate Terraform** -- production-ready, modular code with security best practices
- **Deploy** -- deploy directly to AWS or GCP from the conversation
- **Operate and manage** -- inspect deployments, detect drift, monitor logs, roll back changes

### Supported Services (50+)

| Category | AWS | GCP |
|----------|-----|-----|
| **Compute** | EC2, ECS, EKS, Lambda | Compute Engine, Cloud Run, GKE, Cloud Functions |
| **Database** | RDS PostgreSQL, DynamoDB, ElastiCache, OpenSearch | Cloud SQL, Firestore, Memorystore |
| **Networking** | VPC, ALB, CloudFront, API Gateway | VPC, Load Balancing, Cloud CDN, API Gateway |
| **Storage** | S3 | Cloud Storage |
| **Security** | WAF, KMS, Secrets Manager, Cognito | Cloud Armor, Cloud KMS, Secret Manager, Identity Platform |
| **Messaging** | SQS, MSK (Kafka) | Pub/Sub |
| **Observability** | CloudWatch, Managed Grafana | Cloud Logging, Cloud Monitoring |
| **AI/ML** | Bedrock | Vertex AI |
| **CI/CD** | CodePipeline, GitHub Actions | Cloud Build |
| **Backup** | AWS Backup | GCP Backups |

## Installation

### From GitHub (in Claude Code)

1. Add the marketplace:
   ```
   /plugin marketplace add luthersystems/insideout-claude-code
   ```

2. Install the plugin:
   ```
   /plugin install insideout
   ```

### For Development

```bash
git clone https://github.com/luthersystems/insideout-claude-code.git
claude --plugin-dir ./insideout-claude-code
```

### Custom MCP Server URL

Use the `/insideout:connect` command to point at a different server:

```
/insideout:connect local                    # localhost:8080
/insideout:connect https://custom.url/mcp   # custom URL
/insideout:connect prod                     # reset to production
```

## Quick Start

On first use, Claude Code will ask to approve the InsideOut MCP tools -- select **"Yes, and don't ask again"**. This is a one-time prompt.

Use the `/insideout:start` command or just mention infrastructure in your conversation:

```
You: /insideout:start I need cloud infrastructure for a web app

Riley: "Hi! I'm Riley, your infrastructure advisor. Tell me about the app
        you're building -- what does it do, who uses it, and what scale
        are you planning for?"

You: "It's an e-commerce platform expecting 50k monthly users on AWS"

Riley: "Great! I'd recommend ECS for your containers, RDS PostgreSQL
        for your database, ElastiCache Redis for sessions, and an ALB.
        Estimated cost: ~$350/month. Want me to adjust anything?"

You: "Looks good, generate the Terraform"

[Generates production-ready Terraform files]

You: "Deploy it"

[Deploys to AWS, streams logs in real-time]
```

### Workspace-Aware

InsideOut automatically scans your workspace to detect your tech stack, framework, existing infrastructure, and target cloud provider. This gives Riley immediate context about your project so she can tailor recommendations from the start.

## Available Tools

| Tool | Description |
|------|-------------|
| `convoopen` | Start a new infrastructure design session |
| `convoreply` | Continue the design conversation with Riley |
| `convoawait` | Wait for long-running operations |
| `convostatus` | View current components, config, and pricing |
| `tfgenerate` | Generate production-ready Terraform files |
| `tfdeploy` | Deploy generated Terraform to AWS or GCP |
| `tfplan` | Preview infrastructure changes without applying |
| `tfdestroy` | Tear down deployed infrastructure |
| `tfdrift` | Detect infrastructure drift |
| `tfstatus` | Check deployment progress |
| `tflogs` | Stream real-time deployment logs |
| `tfoutputs` | Get Terraform outputs (VPC IDs, endpoints, etc.) |
| `tfruns` | List all deployment runs for a session |
| `stackversions` | List all design versions |
| `stackdiff` | Compare two stack versions |
| `stackrollback` | Revert to a previous design version |
| `awsinspect` | Inspect deployed AWS resources |
| `gcpinspect` | Inspect deployed GCP resources |
| `credawait` | Poll for cloud credentials |
| `submit_feedback` | Submit bug reports or feature requests |
| `help` | Get workflow guidance |

## How It Works

InsideOut uses a multi-agent AI system behind a single MCP server:

| Agent | Role |
|-------|------|
| **Riley** | Infrastructure advisor -- leads the design conversation |
| **Hippo** | Cost estimation and pricing optimization |
| **Joy** | User experience and requirement gathering |
| **Etch** | Terraform code generation |
| **Core** | Architecture validation and best practices |
| **Axel** | Deployment orchestration |

The conversation flows through these agents automatically. From your perspective, you're talking to Riley -- the other agents work behind the scenes.

## Directory Structure

```
insideout-claude-code/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Self-hosted marketplace definition
├── .mcp.json                    # MCP server configuration (prod)
├── commands/
│   ├── start.md                 # /insideout:start slash command
│   └── connect.md               # /insideout:connect server switching
├── skills/
│   └── insideout/
│       └── SKILL.md             # Agent guidance and activation triggers
├── steering/                    # Workflow-specific guidance
│   ├── getting-started.md
│   ├── aws-design-patterns.md
│   ├── gcp-design-patterns.md
│   └── troubleshooting-guide.md
├── assets/
│   ├── banner.svg
│   └── logo.svg
├── README.md
└── LICENSE
```

## Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/my-improvement`
3. Make your changes
4. Test locally: `claude --plugin-dir ./`
5. Submit a pull request

## License

[Apache License 2.0](LICENSE)

## Links

- [InsideOut Platform](https://insideout.luthersystems.com)
- [Standalone Web App](https://insideout.luthersystemsapp.com/) -- try InsideOut without Claude Code
- [Luther Systems](https://luthersystems.com)
- [Claude Code](https://claude.ai/code)

## Community & Support

- [Discord](https://insideout.luthersystems.com/discord) -- chat with the devs and InsideOut users
- [General Inquiry Call](https://insideout.luthersystems.com/general-call) -- talk with us
- [Tech Call](https://insideout.luthersystems.com/tech-call) -- talk with the devs
