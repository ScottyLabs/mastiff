output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.main.repository_url
}

output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.this.zone_id
}

output "alb_security_group_id" {
  description = "The security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "task_security_group_id" {
  description = "The security group ID attached to the ECS tasks"
  value       = aws_security_group.this.id
}
