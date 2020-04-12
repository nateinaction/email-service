# Prove domain ownership with AWS
resource "aws_ses_domain_identity" "top_level_domain" {
  domain = var.top_level_domain
}

resource "cloudflare_record" "txt_domain_verification" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "_amazonses"
  value   = aws_ses_domain_identity.top_level_domain.verification_token
}

resource "aws_ses_domain_identity_verification" "wait_for_verification" {
  domain = var.top_level_domain

  depends_on = [cloudflare_record.txt_domain_verification]

  timeouts {
    create = "1m"
  }
}

# Setup email sender authenticity record
resource "aws_ses_domain_dkim" "top_level_domain" {
  domain = var.top_level_domain
}

resource "cloudflare_record" "cname_dkim" {
  count = 3

  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "${aws_ses_domain_dkim.top_level_domain.dkim_tokens[count.index]}._domainkey"
  value   = "${aws_ses_domain_dkim.top_level_domain.dkim_tokens[count.index]}.dkim.amazonses.com"
}

# Set which email exchanges are authorized to send mail
resource "cloudflare_record" "txt_spf" {
  zone_id = var.cloudflare_zone_id
  type    = "TXT"
  name    = "@"
  value   = "v=spf1 include:amazonses.com -all"
}

# Set mail receiving record
resource "cloudflare_record" "mx" {
  count = 1

  zone_id  = var.cloudflare_zone_id
  type     = "MX"
  name     = "@"
  value    = "inbound-smtp.${var.aws_region}.amazonaws.com"
  priority = 10
}
