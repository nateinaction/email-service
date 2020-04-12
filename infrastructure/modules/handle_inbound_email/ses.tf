resource "aws_ses_receipt_rule_set" "forwarding_routes" {
  rule_set_name = "forwarding_routes"
}

resource "aws_ses_active_receipt_rule_set" "forwarding_routes" {
  rule_set_name = aws_ses_receipt_rule_set.forwarding_routes.rule_set_name
}

resource "aws_ses_receipt_rule" "forward_to_s3" {
  count = 1
  name          = "forward_to_s3"
  rule_set_name = "forwarding_routes"
  recipients    = [
    for route in var.email_forwarding_routes:
    format("%s@%s", route["alias"], var.top_level_domain)
  ]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = aws_s3_bucket.inbound_email_temporary_storage.bucket
    position = 1
  }
}
