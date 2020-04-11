// Create the SNS topic
resource "aws_sns_topic" "inbound_email" {
  name = "inbound_email_${replace(var.top_level_domain, ".", "_")}"
}

data "aws_iam_policy_document" "inbound_email_to_sns" {
  statement {
    actions = [
      "SNS:Publish",
    ]
    resources = [aws_sns_topic.inbound_email.arn]

    condition {
      test = "StringEquals"
      variable = "aws:SourceOwner"
      values = [var.aws_account_id]
    }

    principals {
      identifiers = ["ses.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_sns_topic_policy" "inbound_email_to_sns" {
  arn    = aws_sns_topic.inbound_email.arn
  policy = data.aws_iam_policy_document.inbound_email_to_sns.json
}
