# Setup email sender authenticity record
resource "aws_ses_domain_dkim" "top_level_domain" {
  domain = var.top_level_domain
}

resource "cloudflare_record" "cname_dkim" {
  count = length(aws_ses_domain_dkim.top_level_domain.dkim_tokens)

  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  name    = "${aws_ses_domain_dkim.top_level_domain.dkim_tokens[count.index]}._domainkey"
  value   = "${aws_ses_domain_dkim.top_level_domain.dkim_tokens[count.index]}.dkim.amazonses.com"
}
