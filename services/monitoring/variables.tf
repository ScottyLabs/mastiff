variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name to use in resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster where tasks will be deployed"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role that the ECS task will use for execution"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "grafana_admin_user" {
  description = "Admin username for Grafana"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}