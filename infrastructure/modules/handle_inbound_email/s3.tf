resource "aws_s3_bucket" "inbound_email_temporary_storage" {
  bucket = "inbound-email-${replace(var.top_level_domain, ".", "-")}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "delete"
    enabled = true

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "inbound_email_temporary_storage" {
  bucket = aws_s3_bucket.inbound_email_temporary_storage.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "inbound_email_temporary_storage" {
  bucket = aws_s3_bucket.inbound_email_temporary_storage.id
  policy = data.aws_iam_policy_document.inbound_email_temporary_storage.json
}

data "aws_iam_policy_document" "inbound_email_temporary_storage" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.inbound_email_temporary_storage.arn}/*"]

    condition {
      test = "StringEquals"
      variable = "aws:Referer"
      values = [var.aws_account_id]
    }

    principals {
      identifiers = ["ses.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.inbound_email_temporary_storage.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.forward_inbound_email.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
