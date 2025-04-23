output "service" {
  description = "The collie service module outputs"
  value       = module.service
}

output "task_role_arn" {
  description = "The ARN of the task role"
  value       = aws_iam_role.collie_task_role.arn
}

output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions role"
  value       = aws_iam_role.github_actions_role.arn
}
