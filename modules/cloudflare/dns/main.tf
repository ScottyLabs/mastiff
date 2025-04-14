resource "cloudflare_zone" "zone" {
  account = {
    id = var.cloudflare_account_id
  }

  for_each = { for domain in var.domains : domain.name => domain }

  name  = each.key
  type = "full"
}

resource "cloudflare_dns_record" "records" {
  for_each = {
    for record in local.flattened_records :
    "${record.domain}-${record.name}-${record.type}" => record
  }

  zone_id  = cloudflare_zone.zone[each.value.domain].id
  name     = each.value.name
  content    = each.value.content
  type     = each.value.type
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  priority = each.value.type == "MX" ? each.value.priority : null
}
