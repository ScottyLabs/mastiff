output "prometheus_url" {
  description = "URL for accessing Prometheus UI"
  value       = "http://${aws_lb.prometheus.dns_name}"
}

output "prometheus_security_group_id" {
  description = "Security group ID for Prometheus"
  value       = aws_security_group.prometheus.id
}

output "prometheus_efs_id" {
  description = "EFS filesystem ID used by Prometheus for data storage"
  value       = aws_efs_file_system.prometheus_data.id
}

output "prometheus_task_role_arn" {
  description = "ARN of the IAM role used by the Prometheus task"
  value       = aws_iam_role.prometheus_task_role.arn
}

output "prometheus_alb_dns_name" {
  description = "DNS name of the load balancer for Prometheus"
  value       = aws_lb.prometheus.dns_name
}

output "prometheus_alb_zone_id" {
  description = "Route 53 zone ID of the load balancer for Prometheus"
  value       = aws_lb.prometheus.zone_id
}