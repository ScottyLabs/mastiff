output "zone_ids" {
  description = "Map of domain names to their Cloudflare zone IDs"
  value       = { for k, v in cloudflare_zone.zone : k => v.id }
}

output "nameservers" {
  description = "Map of domain names to their assigned nameservers"
  value       = { for k, v in cloudflare_zone.zone : k => v.name_servers }
}
