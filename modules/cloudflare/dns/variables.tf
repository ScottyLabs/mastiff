variable "domains" {
  description = "List of domains to manage in Cloudflare"
  type = list(object({
    name       = string
    plan       = string
    account_id = string
    records = optional(list(object({
      name     = string
      type     = string
      content    = string
      ttl      = optional(number, 1)
      proxied  = optional(bool, false)
      priority = optional(number, null)
    })), [])
  }))
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}
