# Set up additional domain records
resource "cloudflare_record" "mx" {
  count = 1

  zone_id  = var.cloudflare_zone_id
  type     = "MX"
  name     = "@"
  value    = "inbound-smtp.${var.aws_region}.amazonaws.com"
  priority = 10
}

resource "cloudflare_record" "txt_spf" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "@"
  value   = "v=spf1 include:amazonses.com -all"
}
