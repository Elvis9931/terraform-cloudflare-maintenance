resource "cloudflare_workers_script" "this" {
  account_id = var.account_id
  name = format("maintenance-%s", replace(var.cloudflare_zone, ".", "-"))
  content = templatefile("${path.module}/maintenance.js", {
    company_name   = var.company_name
    logo_url       = var.logo_url
    favicon_url    = var.favicon_url
    font           = var.font
    email          = var.email
    statuspage_url = var.statuspage_url
    google_font    = replace(var.font, " ", "+")
  })

  plain_text_binding {
    name = "WHITELIST_IPS"
    text = var.whitelist_ips
  }

  plain_text_binding {
    name = "WHITELIST_PATH"
    text = var.whitelist_path
  }
}

data "cloudflare_zones" "this" {
  filter {
    account_id = var.account_id
    name = var.cloudflare_zone
  }
}

resource "cloudflare_workers_route" "this" {
  count       = var.enabled != false ? length(var.patterns) : 0
  zone_id     = lookup(data.cloudflare_zones.this.zones[0], "id")
  pattern     = var.patterns[count.index]
  script_name = cloudflare_workers_script.this.name
}
