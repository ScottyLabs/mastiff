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

variable "uptime_kuma_cpu" {
  description = "CPU units to allocate to the Uptime Kuma container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "uptime_kuma_memory" {
  description = "Memory to allocate to the Uptime Kuma container in MiB"
  type        = number
  default     = 1024
}

variable "uptime_kuma_version" {
  description = "Uptime Kuma Docker image version"
  type        = string
  default     = "1"  # Use "1" for the latest stable version
}

variable "uptime_kuma_desired_count" {
  description = "Number of Uptime Kuma instances to run"
  type        = number
  default     = 1
}

variable "uptime_kuma_port" {
  description = "Port that Uptime Kuma runs on"
  type        = number
  default     = 3001
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Uptime Kuma UI"
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

variable "uptime_kuma_environment_variables" {
  description = "Additional environment variables for Uptime Kuma"
  type        = map(string)
  default     = {}
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