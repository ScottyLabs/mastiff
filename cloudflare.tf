module "cloudflare_dns" {
  source = "./modules/cloudflare/dns"

  cloudflare_account_id = var.cloudflare_account_id

  domains = [
    {
      name       = "cmushits.com"
      plan       = "pro"
      account_id = var.cloudflare_account_id
      records = [

      ]
    },
    {
      name       = "scottylabs.org"
      plan       = "pro"
      account_id = var.cloudflare_account_id
      records = [
        {
          name    = "auth"
          type    = "CNAME"
          content = "naughty-goldberg-iddxkyd15g.projects.oryapis.com"
          ttl     = 1
          proxied = true
        }
      ]
    }
  ]
}
