variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# Task Definition Variables
variable "launch_type" {
  description = "Launch type for the task (EC2 or FARGATE)"
  type        = string
  default     = "FARGATE"
}

variable "network_mode" {
  description = "Network mode for the task definition (only needed for EC2 launch type)"
  type        = string
  default     = "bridge"
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = number
}

variable "execution_role_arn" {
  description = "ARN of the task execution IAM role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task IAM role"
  type        = string
}

variable "container_definitions" {
  description = "List of container definitions"
  type        = list(any)
}

variable "volumes" {
  description = "Map of volumes to mount"
  type = map(object({
    host_path = optional(string)
  }))
  default = {}
}

# Service Variables
variable "desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS service"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the task"
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "List of load balancer configurations"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "deployment_controller_type" {
  description = "Type of deployment controller"
  type        = string
  default     = "ECS"
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds"
  type        = number
  default     = null
}

# ECR Variables
variable "image_tag_mutability" {
  description = "Image tag mutability setting for the ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan ECR images on push"
  type        = bool
  default     = true
}

# CloudWatch Log Group Variables
variable "log_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

# Security Group Variables
variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
    description     = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 
