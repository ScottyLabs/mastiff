variable "environment" {
  description = "The environment name"
  type        = string
}

variable "cluster_arn" {
  description = "The ARN of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "The CIDRs of the private subnets"
  type        = list(string)
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider"
  type        = string
}