// Create the role the lambda will assume
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "email_service_lambda" {
  name = "email_service_${var.top_level_domain}"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

// Allow the role to send email
data "aws_iam_policy_document" "lambda_send_email" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [var.verified_email_tld_identity_arn]

    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = [aws_lambda_function.forward_inbound_email.arn]
    }
  }
}

resource "aws_iam_policy" "lambda_send_email" {
  name        = "lambda_send_email_${var.top_level_domain}"
  path        = "/"
  description = "IAM policy for sending emails from lambda"

  policy = data.aws_iam_policy_document.lambda_send_email.json
}

resource "aws_iam_role_policy_attachment" "lambda_send_email" {
  role       = aws_iam_role.email_service_lambda.name
  policy_arn = aws_iam_policy.lambda_send_email.arn
}

// Create the lambda
data "archive_file" "lambda_payload" {
  type        = "zip"
  source_file  = "${path.module}/forward_email.py"
  output_path = "${path.module}/forward_email.zip"
}

resource "aws_lambda_function" "forward_inbound_email" {
  filename         = data.archive_file.lambda_payload.output_path
  function_name    = "forward_inbound_email_${replace(var.top_level_domain, ".", "_")}"
  role             = aws_iam_role.email_service_lambda.arn
  handler          = "forward_email.lambda_handler"

  source_code_hash = data.archive_file.lambda_payload.output_base64sha256
  runtime          = "python3.7"

  environment {
    variables = {
      email_forwarding_routes = jsonencode(var.email_forwarding_routes)
    }
  }
}

// Allow the S3 to send messages to the lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.forward_inbound_email.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.inbound_email_temporary_storage.arn
}

// Allow lambda to log to cloudwatch
resource "aws_cloudwatch_log_group" "lambda_log_to_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.forward_inbound_email.function_name}"
  retention_in_days = 30
}

resource "aws_iam_policy" "log_to_cloudwatch" {
  name        = "log_to_cloudwatch_${aws_lambda_function.forward_inbound_email.function_name}"
  path        = "/"
  description = "IAM policy for logging to cloudwatch"
  policy      = data.aws_iam_policy_document.log_to_cloudwatch.json
}

data "aws_iam_policy_document" "log_to_cloudwatch" {
  statement {
    actions   = ["logs:CreateLogGroup","logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.email_service_lambda.name
  policy_arn = aws_iam_policy.log_to_cloudwatch.arn
}
