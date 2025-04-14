locals {
  # Flatten records from all domains into a single list for easier management
  flattened_records = flatten([
    for domain in var.domains : [
      for record in domain.records : {
        domain   = domain.name
        name     = record.name
        type     = record.type
        content  = record.content
        ttl      = record.ttl
        proxied  = record.proxied
        priority = record.priority
      }
    ]
  ])
}
