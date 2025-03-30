output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role"
  value       = module.ecs.execution_role_arn
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_db_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  value       = module.rds.db_credentials_secret_arn
}
