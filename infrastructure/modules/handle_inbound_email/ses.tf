resource "aws_ses_receipt_rule_set" "forwarding_routes" {
  rule_set_name = "forwarding_routes"
}

resource "aws_ses_receipt_rule" "forward_to_sns" {
  count = 1
  name          = "forward_to_sns"
  rule_set_name = "forwarding_routes"
  recipients    = [
    for route in var.email_forwarding_routes:
    format("%s@%s", route["alias"], var.top_level_domain)
  ]
  enabled       = true
  scan_enabled  = true

  sns_action {
    topic_arn = aws_sns_topic.inbound_email.arn
    position  = 1
  }
}
