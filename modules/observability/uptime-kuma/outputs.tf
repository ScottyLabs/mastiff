output "uptime_kuma_url" {
  description = "URL for accessing Uptime Kuma UI"
  value       = "http://${aws_lb.uptime_kuma.dns_name}"
}

output "uptime_kuma_security_group_id" {
  description = "Security group ID for Uptime Kuma"
  value       = aws_security_group.uptime_kuma.id
}

output "uptime_kuma_efs_id" {
  description = "EFS filesystem ID used by Uptime Kuma for data storage"
  value       = aws_efs_file_system.uptime_kuma_data.id
}

output "uptime_kuma_task_role_arn" {
  description = "ARN of the IAM role used by the Uptime Kuma task"
  value       = aws_iam_role.uptime_kuma_task_role.arn
}

output "uptime_kuma_alb_dns_name" {
  description = "DNS name of the load balancer for Uptime Kuma"
  value       = aws_lb.uptime_kuma.dns_name
}

output "uptime_kuma_alb_zone_id" {
  description = "Route 53 zone ID of the load balancer for Uptime Kuma"
  value       = aws_lb.uptime_kuma.zone_id
}