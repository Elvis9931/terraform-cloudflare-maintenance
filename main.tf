resource "cloudflare_worker_script" "this" {
  account_id = var.account_id
  name       = format("maintenance-%s", replace(var.cloudflare_zone, ".", "-"))
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
    name       = var.cloudflare_zone
  }
}

resource "cloudflare_worker_route" "this" {
  count       = var.enabled != false ? length(var.patterns) : 0
  zone_id     = lookup(data.cloudflare_zones.this.zones[0], "id")
  pattern     = var.patterns[count.index]
  script_name = cloudflare_worker_script.this.name
}

module "maintenance" {
  source  = "adinhodovic/maintenance/cloudflare"
  version = "0.7.0"
  # insert the 5 required variables here

  account_id = "be01f00a84e25badb7089089e649d1f5"
  cloudflare_api_key = "2d88ee87963a2a22f0cc373b1e64a263"
  cloudflare_email = "d20992599@gmail.com"
  cloudflare_zone = "hzftechnology.com"
  company_name = "HZF TECHNOLOGY LIMITED"
  email = "contact@hzftechnology.com"
  favicon_url = "https://s3.eu-west-1.amazonaws.com/honeylogic.io/media/images/Honeylogic_-_icon.original.height-80.png"
  font = "Poppins"
  logo_url = "https://s3.eu-west-1.amazonaws.com/honeylogic.io/media/images/Honeylogic-blue.original.png"
  patterns = ["hzftechnology.com/*"]
}
