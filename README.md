# 🚀 Terraform by TWS

A hands-on Terraform learning repository covering core to advanced Infrastructure as Code (IaC) concepts on AWS — from basic resource provisioning to EKS cluster deployment.

---

## 📁 Repository Structure

```
Terraform-by-TWS/
│
├── main.tf                  # Basic local_file resource (intro example)
├── providers.tf             # AWS provider configuration (us-east-2)
├── ec2.tf                   # EC2 instance, Key Pair, VPC & Security Group
├── s3.tf                    # S3 bucket resource
├── outputs.tf               # Output values for EC2 (public/private IP & DNS)
├── variables.tf             # Input variables for EC2 config
├── terrafrom.tf             # Terraform backend (S3) & required providers
├── .gitignore
├── .terraform.lock.hcl
│
├── conditional-exp/         # Terraform conditional expressions
├── custom-module/           # Custom reusable Terraform modules
├── meta-arguments/          # Meta-arguments: count, for_each, depends_on, etc.
├── module/                  # Terraform module usage examples
├── remote-infra/            # Remote infrastructure provisioning
└── terraform-EKS/           # EKS cluster provisioning on AWS
```

---

## 📦 Root-Level Resources

### `providers.tf`
Configures the AWS provider targeting the `us-east-2` region.

```hcl
provider "aws" {
  region = "us-east-2"
}
```

---

### `terrafrom.tf`
Declares the required AWS provider version and configures an **S3 remote backend** for storing Terraform state.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "my-bucket-for-terraform-23456"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
```

---

### `ec2.tf`
Provisions a full EC2 setup including:
- **Key Pair** — reads from a local public key file (`terra-key-ec2.pub`)
- **Default VPC** reference
- **Security Group** (`automate-sg`) with inbound rules for:
  - Port `22` (SSH)
  - Port `80` (HTTP)
  - Port `8000` (Custom app)
  - All outbound traffic allowed
- **EC2 Instance** — type and AMI driven by variables, `gp3` root volume

---

### `variables.tf`

| Variable               | Default                    | Type   |
|------------------------|----------------------------|--------|
| `ec2_instance_type`    | `t3.micro`                 | string |
| `ec2_root_storage_size`| `8`                        | number |
| `ec2_ami_id`           | `ami-0e5497a77ef21b5ac`    | string |
| `env`                  | `prod`                     | string |

---

### `s3.tf`
Creates an S3 bucket named `tws-terraform-bucket-vikash`.

```hcl
resource aws_s3_bucket mybucket {
  bucket = "tws-terraform-bucket-vikash"
}
```

---

### `outputs.tf`
Exposes the following EC2 instance values after apply:

| Output             | Description               |
|--------------------|---------------------------|
| `ec2_public_ip`    | Public IP of the instance |
| `ec2_public_dns`   | Public DNS of the instance|
| `ec2_private_ip`   | Private IP of the instance|
| `ec2_private_dns`  | Private DNS of the instance|

---

### `main.tf`
A beginner-friendly intro resource that creates a local file — used to demonstrate the basic Terraform block syntax:

```hcl
# <block> <parameters> {
#   args
# }

resource local_file myfile {
  filename = "automate.txt"
  content  = "Hello, Dosto"
}
```

---

## 📂 Module & Concept Directories

### `conditional-exp/`
Demonstrates the use of **conditional expressions** in Terraform:
```hcl
condition ? true_val : false_val
```
Used for environment-aware resource configuration.

---

### `meta-arguments/`
Covers Terraform **meta-arguments** such as:
- `count` — create multiple instances of a resource
- `for_each` — iterate over maps/sets
- `depends_on` — explicit dependency management
- `lifecycle` — manage resource lifecycle rules

---

### `module/`
Shows how to **call and use Terraform modules** — separating reusable infrastructure components from root configurations.

---

### `custom-module/`
Demonstrates how to **build your own reusable Terraform module** with proper `variables.tf`, `main.tf`, and `outputs.tf` structure inside the module.

---

### `remote-infra/`
Covers **remote infrastructure** setup — provisioning AWS resources and managing state remotely via S3 backend.

---

### `terraform-EKS/`
End-to-end **Amazon EKS (Elastic Kubernetes Service)** cluster provisioning using Terraform, including:
- VPC and networking setup
- EKS control plane
- Node group configuration

---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.0`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with valid credentials
- An existing SSH key pair (`.pub` file) for EC2 access
- An S3 bucket for remote state backend

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/imVikash-ai/Terraform-by-TWS.git
cd Terraform-by-TWS
```

### 2. Configure AWS Credentials
```bash
aws configure
```

### 3. Generate SSH Key (for EC2)
```bash
ssh-keygen -t rsa -b 4096 -f terra-key-ec2
```

### 4. Initialize Terraform
```bash
terraform init
```

### 5. Preview the Plan
```bash
terraform plan
```

### 6. Apply the Configuration
```bash
terraform apply
```

### 7. View Outputs
```bash
terraform output
```

### 8. Destroy Resources
```bash
terraform destroy
```

---

## 🔐 Security Notes

- Never commit `.terraform/`, `*.tfstate`, `*.tfstate.backup`, or private key files.
- The `.gitignore` is already configured to exclude these.
- Ensure your S3 backend bucket is **private** and optionally enable **versioning** and **DynamoDB locking** for state management.

---

## 🤝 Contributing

Pull requests are welcome. For significant changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This repository is open-source and intended for learning purposes.

---

> **Built with ❤️ for the TWS (TrainWithShubham) DevOps community.**