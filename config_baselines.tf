locals {
  config_topics = [
    one(module.config_baseline_cn-northwest-1[*].config_sns_topic),
    one(module.config_baseline_cn-north-1[*].config_sns_topic),
  ]
}

# --------------------------------------------------------------------------------------------------
# Create an IAM Role for AWS Config recorder to publish results and send notifications.
# Reference: https://docs.aws.amazon.com/config/latest/developerguide/gs-cli-prereq.html#gs-cli-create-iamrole
# --------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "recorder_assume_role_policy" {
  count = var.config_baseline_enabled ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "recorder" {
  count = var.config_baseline_enabled ? 1 : 0

  name               = var.config_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.recorder_assume_role_policy[0].json

  permissions_boundary = var.permissions_boundary_arn

  tags = var.tags
}

# See https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
data "aws_iam_policy_document" "recorder_publish_policy" {
  count = var.config_baseline_enabled ? 1 : 0

  statement {
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [local.audit_log_bucket_arn]
  }

  statement {
    actions   = ["s3:PutObject", "s3:PutObjectACl"]
    resources = ["${local.audit_log_bucket_arn}/${var.config_s3_bucket_key_prefix != "" ? "${var.config_s3_bucket_key_prefix}/" : ""}AWSLogs/${var.aws_account_id}/*"]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    actions   = ["sns:Publish"]
    resources = [for topic in local.config_topics : topic.arn if topic != null]
  }

  statement {
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = ["arn:${data.aws_partition.current.partition}:kms:*:${var.aws_account_id}:key/${var.config_sns_topic_kms_master_key_id != null ? var.config_sns_topic_kms_master_key_id : ""}"]
  }
}

resource "aws_iam_role_policy" "recorder_publish_policy" {
  count = var.config_baseline_enabled ? 1 : 0

  name   = var.config_iam_role_policy_name
  role   = one(aws_iam_role.recorder[*].id)
  policy = data.aws_iam_policy_document.recorder_publish_policy[0].json
}

resource "aws_iam_role_policy_attachment" "recorder_read_policy" {
  count = var.config_baseline_enabled ? 1 : 0

  role       = one(aws_iam_role.recorder[*].id)
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# --------------------------------------------------------------------------------------------------
# AWS Config Baseline
# Needs to be set up in each region.
# Global resource types are only recorded in the region specified by var.region.

module "config_baseline_cn-northwest-1" {
  count  = var.config_baseline_enabled && contains(var.target_regions, "cn-northwest-1") ? 1 : 0
  source = "./modules/config-baseline"

  providers = {
    aws = aws.cn-northwest-1
  }

  iam_role_arn                  = one(aws_iam_role.recorder[*].arn)
  s3_bucket_name                = local.audit_log_bucket_id
  s3_key_prefix                 = var.config_s3_bucket_key_prefix
  delivery_frequency            = var.config_delivery_frequency
  sns_topic_name                = var.config_sns_topic_name
  sns_topic_kms_master_key_id   = var.config_sns_topic_kms_master_key_id
  include_global_resource_types = var.config_global_resources_all_regions ? true : var.region == "cn-northwest-1"

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.audit_log]
}
module "config_baseline_cn-north-1" {
  count  = var.config_baseline_enabled && contains(var.target_regions, "cn-north-1") ? 1 : 0
  source = "./modules/config-baseline"

  providers = {
    aws = aws.cn-north-1
  }

  iam_role_arn                  = one(aws_iam_role.recorder[*].arn)
  s3_bucket_name                = local.audit_log_bucket_id
  s3_key_prefix                 = var.config_s3_bucket_key_prefix
  delivery_frequency            = var.config_delivery_frequency
  sns_topic_name                = var.config_sns_topic_name
  sns_topic_kms_master_key_id   = var.config_sns_topic_kms_master_key_id
  include_global_resource_types = var.config_global_resources_all_regions ? true : var.region == "cn-north-1"

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.audit_log]
}

# --------------------------------------------------------------------------------------------------
# Global Config Rules
# --------------------------------------------------------------------------------------------------

resource "aws_config_config_rule" "iam_mfa" {
  count = var.config_baseline_enabled ? 1 : 0

  name = "IAMAccountMFAEnabled"

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  tags = var.tags

  # Ensure this rule is created after all configuration recorders.
  depends_on = [
    module.config_baseline_cn-north-1,
    module.config_baseline_cn-northwest-1,
  ]
}

resource "aws_config_config_rule" "unused_credentials" {
  count = var.config_baseline_enabled ? 1 : 0

  name             = "UnusedCredentialsNotExist"
  input_parameters = "{\"maxCredentialUsageAge\": \"90\"}"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  tags = var.tags

  # Ensure this rule is created after all configuration recorders.
  depends_on = [
    module.config_baseline_cn-north-1,
    module.config_baseline_cn-northwest-1,
  ]
}

resource "aws_config_config_rule" "user_no_policies" {
  count = var.config_baseline_enabled ? 1 : 0

  name = "NoPoliciesAttachedToUser"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  scope {
    compliance_resource_types = [
      "AWS::IAM::User",
    ]
  }

  tags = var.tags

  # Ensure this rule is created after all configuration recorders.
  depends_on = [
    module.config_baseline_cn-north-1,
    module.config_baseline_cn-northwest-1,
  ]
}

resource "aws_config_config_rule" "no_policies_with_full_admin_access" {
  count = var.config_baseline_enabled ? 1 : 0

  name = "NoPoliciesWithFullAdminAccess"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }

  scope {
    compliance_resource_types = [
      "AWS::IAM::Policy",
    ]
  }

  tags = var.tags

  # Ensure this rule is created after all configuration recorders.
  depends_on = [
    module.config_baseline_cn-north-1,
    module.config_baseline_cn-northwest-1,
  ]
}

# --------------------------------------------------------------------------------------------------
# Aggregator View
# Only created for the master account.
# --------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "config_organization_assume_role_policy" {
  count = var.config_baseline_enabled ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_organization" {
  count = var.config_baseline_enabled && local.is_master_account ? 1 : 0

  name_prefix        = var.config_aggregator_name_prefix
  assume_role_policy = data.aws_iam_policy_document.config_organization_assume_role_policy[0].json

  permissions_boundary = var.permissions_boundary_arn

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config_organization" {
  count = var.config_baseline_enabled && local.is_master_account ? 1 : 0

  role       = aws_iam_role.config_organization[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_partition.current.partition}:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "organization" {
  count = var.config_baseline_enabled && local.is_master_account ? 1 : 0

  name = var.config_aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_organization[0].arn
  }

  tags = var.tags
}

