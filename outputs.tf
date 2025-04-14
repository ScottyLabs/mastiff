output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
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

output "cloudflare_zone_ids" {
  description = "Map of domain names to their Cloudflare zone IDs"
  value       = module.cloudflare_dns.zone_ids
}

output "cloudflare_nameservers" {
  description = "Map of domain names to their assigned nameservers"
  value       = module.cloudflare_dns.nameservers
}
