output "otel_security_group_id" {
  description = "Security group ID for OpenTelemetry Collector"
  value       = aws_security_group.otel.id
}

output "otel_task_role_arn" {
  description = "ARN of the IAM role used by the OpenTelemetry Collector task"
  value       = aws_iam_role.otel_task_role.arn
}

output "otel_service_discovery_namespace" {
  description = "Service discovery namespace for OpenTelemetry"
  value       = aws_service_discovery_private_dns_namespace.otel.name
}

output "otel_service_discovery_service" {
  description = "Service discovery service for OpenTelemetry"
  value       = aws_service_discovery_service.otel.name
}

output "otel_grpc_endpoint" {
  description = "OTLP/gRPC endpoint for OpenTelemetry Collector"
  value       = "otel-collector.${aws_service_discovery_private_dns_namespace.otel.name}:4317"
}

output "otel_http_endpoint" {
  description = "OTLP/HTTP endpoint for OpenTelemetry Collector"
  value       = "otel-collector.${aws_service_discovery_private_dns_namespace.otel.name}:4318"
}