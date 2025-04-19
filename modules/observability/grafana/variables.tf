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

variable "grafana_cpu" {
  description = "CPU units to allocate to the Grafana container (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "grafana_memory" {
  description = "Memory to allocate to the Grafana container in MiB"
  type        = number
  default     = 2048
}

variable "grafana_version" {
  description = "Grafana Docker image version"
  type        = string
  default     = "9.5.2"
}

variable "grafana_desired_count" {
  description = "Number of Grafana instances to run"
  type        = number
  default     = 1
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

variable "prometheus_url" {
  description = "URL of the Prometheus server to use as a datasource"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Grafana UI"
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

variable "grafana_domain" {
  description = "Domain name for Grafana"
  type        = string
  default     = ""
}