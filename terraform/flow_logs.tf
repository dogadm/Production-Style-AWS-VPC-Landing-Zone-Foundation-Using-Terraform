resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc-flow-logs/${local.name_prefix}"
  retention_in_days = var.flow_log_retention_days

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

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
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

  tags = {
    Name = "${local.name_prefix}-flow-log-cloudwatch"
  }
}

resource "random_id" "flow_logs_bucket_suffix" {
  count = var.enable_flow_logs ? 1 : 0

  byte_length = 4
}

resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket        = "${local.name_prefix}-flow-logs-${random_id.flow_logs_bucket_suffix[0].hex}"
  force_destroy = true

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

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    id     = "expire-old-flow-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

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

  tags = {
    Name = "${local.name_prefix}-flow-log-s3"
  }
}
