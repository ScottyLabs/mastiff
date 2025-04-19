output "prometheus_url" {
  description = "URL for accessing Prometheus UI"
  value       = module.prometheus.prometheus_url
}

output "prometheus_security_group_id" {
  description = "Security group ID for Prometheus"
  value       = module.prometheus.prometheus_security_group_id
}

output "prometheus_efs_id" {
  description = "EFS filesystem ID used by Prometheus for data storage"
  value       = module.prometheus.prometheus_efs_id
}

output "prometheus_task_role_arn" {
  description = "ARN of the IAM role used by the Prometheus task"
  value       = module.prometheus.prometheus_task_role_arn
}

output "grafana_url" {
  description = "URL for accessing Grafana UI"
  value       = module.grafana.grafana_url
}

output "grafana_efs_id" {
  description = "EFS filesystem ID used by Grafana for data storage"
  value       = module.grafana.grafana_efs_id
}

output "uptime_kuma_url" {
  description = "URL for accessing Uptime Kuma UI"
  value       = module.uptime_kuma.uptime_kuma_url
}

output "uptime_kuma_efs_id" {
  description = "EFS filesystem ID used by Uptime Kuma for data storage"
  value       = module.uptime_kuma.uptime_kuma_efs_id
}