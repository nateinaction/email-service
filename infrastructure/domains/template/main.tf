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

# Prove domain ownership with AWS
module "verify_domain_ownership" {
  source = "../../modules/verify_domain_ownership"

  top_level_domain   = var.top_level_domain
  cloudflare_zone_id = var.cloudflare_zone_id
}

# Setup DKIM: email sender authenticity record
module "authenticate_sender" {
  source = "../../modules/authenticate_sender"

  top_level_domain   = var.top_level_domain
  cloudflare_zone_id = var.cloudflare_zone_id
}

# Setup additional domain records e.g. MX, SPF
module "setup_dns_records" {
  source = "../../modules/setup_dns_records"

  aws_region         = var.aws_region
  top_level_domain   = var.top_level_domain
  cloudflare_zone_id = var.cloudflare_zone_id
}

# Handle incoming email
## lambda to process mail: needs recipient/fowarding mapping https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/
## iam policy for lambda to send mail https://www.terraform.io/docs/providers/aws/r/ses_identity_policy.html
## ses recipient rule https://www.terraform.io/docs/providers/aws/r/ses_receipt_rule.html
module "handle_inbound_email" {
  source = "../../modules/handle_inbound_email"

  aws_account_id = var.aws_account_id
  top_level_domain                = var.top_level_domain
  verified_email_tld_identity_arn = module.verify_domain_ownership.verified_email_tld_identity_arn
  email_forwarding_routes         = var.email_forwarding_routes
}
