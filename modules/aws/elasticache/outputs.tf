output "replication_group_id" {
  description = "The ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint_address" {
  description = "The connection endpoint for the primary node of the replication group"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "The connection endpoint for the reader nodes of the replication group (if applicable)"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "security_group_id" {
  description = "The ID of the security group created for the ElastiCache cluster"
  value       = aws_security_group.elasticache.id
}
