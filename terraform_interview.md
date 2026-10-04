# Terraform Scenario-Based Interview Questions

A quick-reference guide covering 10 scenario-based Terraform questions with concise answers and example snippets. Useful for DevOps / Cloud Engineer interview preparation.

## Table of Contents

1. [Managing state for team collaboration](#q1-managing-state-for-team-collaboration)
2. [Handling sensitive data](#q2-handling-sensitive-data)
3. [Rolling back a failed deployment](#q3-rolling-back-a-failed-deployment)
4. [Managing resource dependencies](#q4-managing-resource-dependencies)
5. [Structuring reusable modules](#q5-structuring-reusable-modules)
6. [Importing existing infrastructure](#q6-importing-existing-infrastructure)
7. [Multi-region deployments](#q7-multi-region-deployments)
8. [Blue-green deployments](#q8-blue-green-deployments)
9. [Securing state files](#q9-securing-state-files)
10. [Full web application stack on AWS](#q10-full-web-application-stack-on-aws)

---

## Q1. Managing state for team collaboration

**Scenario:** How would you manage state in Terraform so multiple team members can work on the infrastructure simultaneously without conflicts?

**Answer:**
- Use a **remote backend** such as Amazon S3, Google Cloud Storage, or Azure Blob Storage so everyone works from the same, latest state.
- Enable **state locking** so only one operation can modify the state at a time. On AWS, use an S3 backend with a DynamoDB table for locking.
- Use **workspaces** to manage different environments (dev, staging, production) within the same configuration and avoid cross-environment conflicts.

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

```bash
terraform workspace new staging
terraform workspace select staging
```

---

## Q2. Handling sensitive data

**Scenario:** How do you handle sensitive data, such as passwords and API keys, in Terraform configurations?

**Answer:**
- Never hardcode secrets in `.tf` files.
- Pass them through **environment variables** using the `TF_VAR_` prefix (e.g. `TF_VAR_db_password` is read as `var.db_password`).
- Store and retrieve secrets with tools like **HashiCorp Vault**, **AWS Secrets Manager**, or **Azure Key Vault**, fetched through Terraform providers/data sources at apply time.
- Mark variables as `sensitive = true` to hide them from CLI output.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

```bash
export TF_VAR_db_password="super-secret"
```

> **Note:** Values used in resources can still end up in the state file in plain text. Always encrypt the state backend and restrict access to it (see [Q9](#q9-securing-state-files)).

---

## Q3. Rolling back a failed deployment

**Scenario:** Describe a situation where you needed to roll back a failed Terraform deployment. How did you handle it?

**Answer:**
- First understand the current state and determine the safest way to revert.
- **Simple case:** if a newly added resource caused the failure, remove it from the configuration and re-apply.
- **Complex case:** use **Git** to revert to the last known good commit so the configuration matches the previous working state.
- After reverting the configuration, run `terraform apply` to align the infrastructure with it.
- Keep **regular state backups** (or a versioned remote backend) so you can restore a known good state after severe issues.

```bash
git revert <bad-commit>
terraform plan
terraform apply
```

---

## Q4. Managing resource dependencies

**Scenario:** How do you handle dependencies between resources to ensure correct creation and deletion order?

**Answer:**
- **Implicit dependencies:** created automatically when one resource references another's attributes. For example, referencing a security group ID in an EC2 instance ensures the security group is created first.
- **Explicit dependencies:** defined with the `depends_on` meta-argument when no attribute reference exists, e.g. making sure an IAM role exists before an EC2 instance.

```hcl
# Implicit
resource "aws_instance" "web" {
  ami                    = "ami-12345678"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# Explicit
resource "aws_instance" "app" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  depends_on    = [aws_iam_role.my_role]
}
```

---

## Q5. Structuring reusable modules

**Scenario:** As a DevOps engineer setting up infrastructure for microservices across multiple environments, how would you structure and manage Terraform modules for reuse and maintainability?

**Answer:**
- Design modules with **input variables and output values** so they are generic and configurable.
- Each module should encapsulate a specific set of resources (e.g. VPC, EC2, RDS).
- Store modules in a **dedicated Git repository or private registry** for version control and updates.
- Use **semantic versioning** to manage versions and keep compatibility across projects.
- **Document** modules with examples and usage instructions.

```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── ec2/
└── rds/
```

```hcl
module "vpc" {
  source = "git::https://github.com/my-org/terraform-modules.git//vpc?ref=v1.2.0"
  cidr   = "10.0.0.0/16"
}
```

---

## Q6. Importing existing infrastructure

**Scenario:** Describe a situation where you had to import existing infrastructure into Terraform. What challenges did you face and how did you overcome them?

**Answer:**
- Importing requires careful planning and execution.
- Use the `terraform import` command, then write the matching resource block in the configuration without causing drift.
- **Challenges:** matching resource attributes to the real resource's settings, and handling resources not directly supported by the import command.
- **Solution:** make manual adjustments and validate with `terraform plan` until it shows no changes.

```bash
terraform import aws_instance.my_instance i-12345678
terraform plan   # should show no changes once the config matches
```

```hcl
resource "aws_instance" "my_instance" {
  # attributes matching the existing instance
}
```

---

## Q7. Multi-region deployments

**Scenario:** You must deploy a highly available application across multiple AWS regions for low latency and fault tolerance. How would you configure Terraform to handle this?

**Answer:**
- Define a **provider block per region**, using `alias` for additional regions.
- Use **modules** to standardize the deployment across regions.
- Use **workspaces** for environment-specific configuration, and **remote backends** to store state separately per region for isolation and consistency.

```hcl
provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "app_east" {
  source    = "./modules/app"
  providers = { aws = aws.us_east_1 }
}
```

---

## Q8. Blue-green deployments

**Scenario:** You're leading a team deploying a new version of a web application using a blue-green strategy on AWS. How do you use Terraform to switch traffic with minimal downtime and rollback capability?

**Answer:**
- Terraform automates the creation of the **new environment** while the **current version keeps running**. (Convention: *blue* = current/live, *green* = new version.)
- The configuration defines both environments with separate sets of resources (EC2 instances, load balancers, etc.).
- Once the new environment is ready and tested, update **DNS records or load balancer settings** to point to it. This completes the switch.
- Rollback is simply pointing traffic back to the old environment.
- `terraform apply` automates creation and configuration for a smooth, consistent process.

```hcl
variable "active_environment" {
  default = "blue" # change to "green" to switch traffic
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.front.arn

  action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  }

  condition {
    path_pattern { values = ["/*"] }
  }
}
```

---

## Q9. Securing state files

**Scenario:** How do you manage Terraform state files to ensure security and prevent unauthorized access?

**Answer:**
- Use **remote backends with access controls**, e.g. an S3 bucket with encryption and access limited through **IAM policies**.
- Use **state locking** (e.g. DynamoDB on AWS) to prevent simultaneous modifications.
- Keep sensitive data out of state where possible by using environment variables and secret management tools.
- **Audit access logs** regularly and enable **versioning** on the state bucket.

```hcl
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
  }
}
```

---

## Q10. Full web application stack on AWS

**Scenario:** You're deploying a scalable web application on AWS needing VPC networking, EC2 web servers, an RDS database, and security groups. How would you structure the Terraform configuration while maintaining scalability and security best practices?

**Answer:**
- **Networking:** VPC, subnets, route tables, and security groups.
- **Compute:** EC2 instances, or managed services such as AWS ECS or EKS.
- **Database:** RDS instances or other managed database services.
- Each resource block specifies its configuration: instance types, AMIs, security group rules, database parameters.
- Use **modules** for each component (networking, compute, database) for reusability and maintainability.
- Run `terraform apply` to provision everything, with dependencies and relationships handled automatically.

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── networking/   # VPC, subnets, route tables, SGs
    ├── compute/      # EC2 / ECS / EKS
    └── database/     # RDS
```

```hcl
module "networking" {
  source   = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "compute" {
  source     = "./modules/compute"
  subnet_ids = module.networking.private_subnet_ids
  web_sg_id  = module.networking.web_sg_id
}

module "database" {
  source     = "./modules/database"
  subnet_ids = module.networking.db_subnet_ids
  db_sg_id   = module.networking.db_sg_id
}
```

**Security best practices:** keep the database in private subnets, allow only the web tier's security group to reach the DB port, and avoid hardcoded credentials.

---

## Quick Command Reference

| Command | Purpose |
|---|---|
| `terraform init` | Initialize backend and providers |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform import` | Bring existing resources under Terraform management |
| `terraform workspace` | Manage workspaces |
| `terraform state` | Inspect and manipulate state 