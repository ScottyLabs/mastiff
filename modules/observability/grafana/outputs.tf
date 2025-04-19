output "grafana_url" {
  description = "URL for accessing Grafana UI"
  value       = "http://${aws_lb.grafana.dns_name}"
}

output "grafana_security_group_id" {
  description = "Security group ID for Grafana"
  value       = aws_security_group.grafana.id
}

output "grafana_efs_id" {
  description = "EFS filesystem ID used by Grafana for data storage"
  value       = aws_efs_file_system.grafana_data.id
}

output "grafana_task_role_arn" {
  description = "ARN of the IAM role used by the Grafana task"
  value       = aws_iam_role.grafana_task_role.arn
}

output "grafana_alb_dns_name" {
  description = "DNS name of the load balancer for Grafana"
  value       = aws_lb.grafana.dns_name
}

output "grafana_alb_zone_id" {
  description = "Route 53 zone ID of the load balancer for Grafana"
  value       = aws_lb.grafana.zone_id
}