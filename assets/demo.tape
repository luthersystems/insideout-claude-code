# InsideOut Demo — AI-Powered Cloud Infrastructure Design
# Generated with VHS (https://github.com/charmbracelet/vhs)

Output assets/demo.gif

Set Shell "bash"
Set FontSize 14
Set Width 900
Set Height 500
Set Padding 15
Set Theme "Dracula"
Set TypingSpeed 40ms

Sleep 500ms

Type "claude"
Enter
Sleep 2s

Type "/insideout I need AWS infrastructure for a Node.js e-commerce app with 50k monthly users"
Sleep 500ms
Enter

Sleep 3s

# Simulated Riley response
Type "# Riley: Hi! I'd recommend ECS Fargate for your containers, RDS PostgreSQL"
Enter
Sleep 300ms
Type "# for your database, ElastiCache Redis for sessions, and an ALB with"
Enter
Sleep 300ms
Type "# CloudFront CDN. Estimated cost: ~$350/month."
Enter
Sleep 2s

Type "Looks good! Generate the Terraform."
Sleep 500ms
Enter

Sleep 2s

# Simulated Terraform generation
Type "# Generating production-ready Terraform..."
Enter
Sleep 1s
Type "# ✓ VPC with public/private subnets"
Enter
Sleep 300ms
Type "# ✓ ECS Fargate cluster + service"
Enter
Sleep 300ms
Type "# ✓ RDS PostgreSQL (db.t3.medium)"
Enter
Sleep 300ms
Type "# ✓ ElastiCache Redis cluster"
Enter
Sleep 300ms
Type "# ✓ ALB + CloudFront distribution"
Enter
Sleep 300ms
Type "# ✓ WAF, KMS, Secrets Manager"
Enter
Sleep 1s
Type "# Terraform files ready! Deploy with tfdeploy."
Enter

Sleep 3s
