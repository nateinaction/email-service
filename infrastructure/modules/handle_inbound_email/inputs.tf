// General
variable "top_level_domain" {
  description = "The top level domain where we'll be sending and receiving email"
  type        = string
}
variable "email_forwarding_routes" {
  description = "Mapping of inbound addresses to fowarding addresses"
  type        = list(map(string))
}

// AWS
variable "aws_account_id" {
  description = "Amazon account ID"
  type        = string
}
variable "verified_email_tld_identity_arn" {
  description = "ARN for a verified SES domain identity"
  type        = string
}
