provider "aws" {
  version = "~> 2.23.0"
  region  = var.aws_region
}

provider "cloudflare" {
  version    = "~> 2.0"
  email      = var.cloudflare_email
  api_token  = var.cloudflare_api_token
  account_id = var.cloudflare_account_id
}

module "setup_domain" {
  source = "../../modules/setup_domain"

  aws_region         = var.aws_region
  top_level_domain   = var.top_level_domain
  cloudflare_zone_id = var.cloudflare_zone_id
}

module "handle_inbound_email" {
  source = "../../modules/handle_inbound_email"

  aws_account_id = var.aws_account_id
  top_level_domain                = var.top_level_domain
  verified_email_tld_identity_arn = module.setup_domain.verified_email_tld_identity_arn
  email_forwarding_routes         = var.email_forwarding_routes
}
