// Create the SNS topic
resource "aws_sns_topic" "inbound_email" {
  name = "inbound_email_${replace(var.top_level_domain, ".", "_")}"

  lambda_success_feedback_role_arn = aws_iam_role.sns_log_to_cloudwatch.arn
  lambda_success_feedback_sample_rate = 100
  lambda_failure_feedback_role_arn = aws_iam_role.sns_log_to_cloudwatch.arn
}

// Allow the SNS topic to receive emails from SES
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

// Allow the SNS to log to cloudwatch
data "aws_iam_policy_document" "sns_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sns_log_to_cloudwatch" {
  name = "sns_to_cloudwatch_${var.top_level_domain}"

  assume_role_policy = data.aws_iam_policy_document.sns_assume_role.json
}

data "aws_iam_policy_document" "sns_log_to_cloudwatch" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sns_log_to_cloudwatch" {
  name        = "sns_log_to_cloudwatch_${var.top_level_domain}"
  path        = "/"
  description = "IAM policy for sns to log to cloudwatch"

  policy = data.aws_iam_policy_document.sns_log_to_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "sns_log_to_cloudwatch" {
  role       = aws_iam_role.sns_log_to_cloudwatch.name
  policy_arn = aws_iam_policy.sns_log_to_cloudwatch.arn
}
