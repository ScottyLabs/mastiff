variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "scottylabs"
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
  default     = "scottylabs"
}

variable "bastion_key_name" {
  description = "The name of the SSH key to use for the bastion host"
  type        = string
  default     = "scottylabs-bastion-key"
}

variable "allowed_bastion_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Consider restricting this to your organization's IP ranges
}
