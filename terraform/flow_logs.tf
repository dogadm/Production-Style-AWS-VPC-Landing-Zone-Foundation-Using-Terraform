resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc-flow-logs/${local.name_prefix}"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name = "${local.name_prefix}-flow-logs-cw"
  }
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
      ]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name               = "${local.name_prefix}-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json

  tags = {
    Name = "${local.name_prefix}-flow-logs-role"
  }
}

data "aws_iam_policy_document" "flow_logs_to_cloudwatch" {
  count = var.enable_flow_logs ? 1 : 0

  # checkov:skip=CKV_AWS_356: logs:DescribeLogGroups does not support resource-level authorization and therefore requires Resource "*".

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams"
    ]

    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs[0].arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }
}



resource "aws_iam_role_policy" "flow_logs_to_cloudwatch" {
  count = var.enable_flow_logs ? 1 : 0

  name   = "${local.name_prefix}-flow-logs-cw-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_to_cloudwatch[0].json
}

resource "aws_flow_log" "cloudwatch" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  depends_on = [
    aws_iam_role_policy.flow_logs_to_cloudwatch
  ]

  tags = {
    Name = "${local.name_prefix}-flow-log-cloudwatch"
  }
}

resource "random_id" "flow_logs_bucket_suffix" {
  count = var.enable_flow_logs ? 1 : 0

  byte_length = 4
}


# S3 server access logging would require a dedicated secondary logging
# destination and is intentionally deferred for this portfolio environment.
#tfsec:ignore:aws-s3-enable-bucket-logging
#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  # Controls implemented through separate AWS provider resources
  # checkov:skip=CKV_AWS_19: Bucket encryption is configured separately through aws_s3_bucket_server_side_encryption_configuration.flow_logs using SSE-KMS.
  # checkov:skip=CKV_AWS_21: Bucket versioning is enabled separately through aws_s3_bucket_versioning.flow_logs, following the current AWS provider resource model.
  # checkov:skip=CKV_AWS_145: Default SSE-KMS encryption is configured separately through aws_s3_bucket_server_side_encryption_configuration.flow_logs using the customer-managed Flow Logs KMS key.
  # checkov:skip=CKV2_AWS_61: Lifecycle configuration is defined separately in aws_s3_bucket_lifecycle_configuration.flow_logs.
  # checkov:skip=CKV2_AWS_6: Public Access Block is defined separately in aws_s3_bucket_public_access_block.flow_logs.

  # Architecturally deferred controls
  # checkov:skip=CKV_AWS_144: Cross-region replication is intentionally deferred because multi-region log durability is outside the scope of this single-region portfolio environment.
  # checkov:skip=CKV_AWS_18: S3 server access logging to a dedicated secondary logging bucket is intentionally deferred for this portfolio environment.
  # checkov:skip=CKV2_AWS_62: S3 event notifications are not currently an architectural requirement for the VPC Flow Logs bucket.

  bucket        = "${local.name_prefix}-flow-logs-${random_id.flow_logs_bucket_suffix[0].hex}"
  force_destroy = false

  tags = {
    Name = "${local.name_prefix}-flow-logs-s3"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-old-flow-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }
  }
}


resource "aws_flow_log" "s3" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination      = aws_s3_bucket.flow_logs[0].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  depends_on = [
    aws_s3_bucket_policy.flow_logs,
    aws_s3_bucket_server_side_encryption_configuration.flow_logs
  ]

  tags = {
    Name = "${local.name_prefix}-flow-log-s3"
  }
}


resource "aws_s3_bucket_versioning" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count  = var.enable_flow_logs ? 1 : 0
  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.flow_logs.arn
    }

    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "flow_logs_s3" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.flow_logs[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.flow_logs[0].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_s3[0].json
}
