// General
variable "top_level_domain" {
  description = "The top level domain where we'll be sending and receiving email"
  type        = string
}
variable "email_forwarding_routes" {
  description = "Mapping of inbound addresses to fowarding addresses"
  type        = list(map(string))
}
variable "email_aliases_with_smtp_access" {
  description = "Email aliases with SMTP users/passwords"
  type        = list(string)
}

// AWS
variable "aws_account_id" {
  description = "Amazon account ID"
  type        = string
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

// Cloudflare
variable "cloudflare_email" {
  description = "Email address for the Cloudflare account"
  type        = string
}
variable "cloudflare_api_token" {
  description = "Limited scope Cloudflare API token"
  type        = string
}
variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}
variable "cloudflare_zone_id" {
  description = "Zone ID for the domain managed by Cloudflare"
  type        = string
}
