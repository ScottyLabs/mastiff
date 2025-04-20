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

variable "otel_cpu" {
  description = "CPU units to allocate to the OpenTelemetry container (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "otel_memory" {
  description = "Memory to allocate to the OpenTelemetry container in MiB"
  type        = number
  default     = 1024
}

variable "otel_version" {
  description = "OpenTelemetry Collector Docker image version"
  type        = string
  default     = "0.91.0"
}

variable "otel_image" {
  description = "OpenTelemetry Collector Docker image"
  type        = string
  default     = "otel/opentelemetry-collector-contrib"
}

variable "otel_desired_count" {
  description = "Number of OpenTelemetry instances to run"
  type        = number
  default     = 1
}

variable "prometheus_endpoint" {
  description = "Prometheus endpoint URL for remote write"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "internal_port" {
  description = "Whether the ports should be internal"
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