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

variable "prometheus_cpu" {
  description = "CPU units to allocate to the Prometheus container (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "prometheus_memory" {
  description = "Memory to allocate to the Prometheus container in MiB"
  type        = number
  default     = 2048
}

variable "prometheus_version" {
  description = "Prometheus Docker image version"
  type        = string
  default     = "v2.45.0"
}

variable "prometheus_retention_days" {
  description = "Data retention period in days"
  type        = string
  default     = "15d"
}

variable "prometheus_desired_count" {
  description = "Number of Prometheus instances to run"
  type        = number
  default     = 1
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Prometheus UI"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "internal_alb" {
  description = "Whether the ALB should be internal"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}