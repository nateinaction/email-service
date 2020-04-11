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
