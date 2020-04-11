// General
variable "top_level_domain" {
  description = "The top level domain where we'll be sending and receiving email"
  type = string
}

//AWS
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

// Cloudflare
variable "cloudflare_zone_id" {
  description = "Zone ID for the domain managed by Cloudflare"
  type        = string
}
