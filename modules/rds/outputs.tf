output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.this.id
}

output "db_parameter_group_id" {
  description = "The db parameter group name"
  value       = aws_db_parameter_group.this.id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.this.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this.status
}

output "security_group_id" {
  description = "The ID of the security group created for the RDS instance"
  value       = aws_security_group.rds.id
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  value       = var.manage_master_user_password ? aws_db_instance.this.master_user_secret[0].secret_arn : null
}

output "db_credentials_secret_id" {
  description = "The ID of the Secrets Manager secret containing database credentials (last part of the ARN)"
  value       = var.manage_master_user_password ? replace(aws_db_instance.this.master_user_secret[0].secret_arn, ".*:", "") : null
}
