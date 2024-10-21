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

provider "cloudflare" {
  email   = "d20992599@gmail.com"
  api_key = "4d8dfa89d03b4b4d3ef622479c50f29ca3faf"
}

module "martian_com_co_maintenance" {
  source  = "adinhodovic/maintenance/cloudflare"
  version = "0.7.0"
  account_id = "be01f00a84e25badb7089089e649d1f5"
  cloudflare_zone = "martian.com.co"
  patterns = ["martian.com.co/abc"]
  company_name = "MARTIAN Inc."
  email = "contact@martian.com.co"
  font = "Lato"
  logo_url = "https://testingcf.jsdelivr.net/gh/Elvis9931/iOS_Script_Rule/icon/MCloud_1.svg"
}
