resource "aws_kms_key" "flow_logs" {
  description         = "KMS key for ${local.name_prefix} VPC Flow Logs"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.flow_logs_kms.json

  tags = {
    Name = "${local.name_prefix}-flow-logs-kms"
  }
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${local.name_prefix}-flow-logs"
  target_key_id = aws_kms_key.flow_logs.key_id
}

data "aws_iam_policy_document" "flow_logs_kms" {

  # checkov:skip=CKV_AWS_109: This is a KMS resource policy. The account-root kms:* statement enables administration and IAM delegation for this specific KMS key; Resource "*" in a KMS key policy means this key only.
  # checkov:skip=CKV_AWS_111: KMS cryptographic write permissions are restricted to explicit AWS service principals and constrained by encryption-context or source-account/source-ARN conditions.
  # checkov:skip=CKV_AWS_356: This is a KMS key policy; AWS KMS requires Resource "*" in key policy statements, where "*" means the specific KMS key to which the policy is attached.
  # Enable the AWS account to administer the key and delegate access through IAM.
  # In a KMS key policy, Resource "*" refers to this KMS key only.

  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  # Allow CloudWatch Logs to encrypt/decrypt VPC Flow Logs

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.aws_region}.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc-flow-logs/${local.name_prefix}*"
      ]
    }
  }

  # Required if the same key encrypts the S3 Flow Logs bucket
  statement {
    sid    = "AllowFlowLogDeliveryToS3"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }
}