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
    # dynamodb_table = "tws-junoon-state-table"
    use_lockfile = true
  }
}
