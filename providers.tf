provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  backend "s3" {
    bucket       = "scottylabs-terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
    profile      = "scottylabs-gabriel"
  }
}
