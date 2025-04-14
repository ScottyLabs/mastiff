output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "execution_role_id" {
  description = "The ID of the ECS execution role"
  value       = aws_iam_role.execution_role.id
}

output "execution_role_arn" {
  description = "The ARN of the ECS execution role"
  value       = aws_iam_role.execution_role.arn
}

output "execution_role_name" {
  description = "The name of the ECS execution role"
  value       = aws_iam_role.execution_role.name
}
