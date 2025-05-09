provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }

  backend "s3" {
    bucket         = "scottylabs-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "scottylabs-terraform-locks"
    encrypt        = true
    profile        = "scottylabs-gabriel"
  }
}
