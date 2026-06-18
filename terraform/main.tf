terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }

  # Production recommendation:
  # Configure a remote backend using S3 and DynamoDB state locking.
  # backend "s3" {
  #   bucket         = "replace-with-terraform-state-bucket"
  #   key            = "secure-vpc/terraform.tfstate"
  #   region         = "eu-west-2"
  #   dynamodb_table = "replace-with-lock-table"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Secure AWS VPC Portfolio Project"
  }
}
