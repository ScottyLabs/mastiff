variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service"
}

variable "desired_count" {
  description = "Desired number of tasks to run in the service"
  type        = number
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "Maximum number of tasks that can be running at the same time"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum number of tasks that must be running at the same time"
  type        = number
  default     = 100
}

variable "health_check_grace_period_seconds" {
  description = "Grace period for the health check"
  type        = number
  default     = 300
}

variable "cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

variable "tags" {
  description = "List of tags to be associated with resources."
  default     = {}
  type        = any
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for the health check endpoint"
  type        = string
  default     = "/"
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "alb_enable_deletion_protection" {
  description = "Whether to enable deletion protection on the ALB"
  type        = bool
  default     = false
}
