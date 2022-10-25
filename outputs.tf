# --------------------------------------------------------------------------------------------------
# Outputs from the root module.
# --------------------------------------------------------------------------------------------------

output "audit_bucket" {
  description = "The S3 bucket used for storing audit logs."
  value       = one(module.audit_log_bucket[*].this_bucket)
}

# --------------------------------------------------------------------------------------------------
# Outputs from alarm-baseline module.
# --------------------------------------------------------------------------------------------------

output "alarm_sns_topic" {
  description = "The SNS topic to which CloudWatch Alarms will be sent."
  value       = one(module.alarm_baseline[*].alarm_sns_topic)
}

# --------------------------------------------------------------------------------------------------
# Outputs from cloudtrail-baseline module.
# --------------------------------------------------------------------------------------------------

output "cloudtrail" {
  description = "The trail for recording events in all regions."
  value       = one(module.cloudtrail_baseline[*].cloudtrail)
}

output "cloudtrail_sns_topic" {
  description = "The sns topic linked to the cloudtrail."
  value       = one(module.cloudtrail_baseline[*].cloudtrail_sns_topic)
}

output "cloudtrail_kms_key" {
  description = "The KMS key used for encrypting CloudTrail events."
  value       = one(module.cloudtrail_baseline[*].kms_key)
}

output "cloudtrail_log_delivery_iam_role" {
  description = "The IAM role used for delivering CloudTrail events to CloudWatch Logs."
  value       = one(module.cloudtrail_baseline[*].log_delivery_iam_role)
}

output "cloudtrail_log_group" {
  description = "The CloudWatch Logs log group which stores CloudTrail events."
  value       = one(module.cloudtrail_baseline[*].log_group)
}

# --------------------------------------------------------------------------------------------------
# Outputs from config-baseline module.
# --------------------------------------------------------------------------------------------------

output "config_iam_role" {
  description = "The IAM role used for delivering AWS Config records to CloudWatch Logs."
  value       = aws_iam_role.recorder
}

output "config_configuration_recorder" {
  description = "The configuration recorder in each region."

  value = {
    "cn-northwest-1"      = one(module.config_baseline_cn-northwest-1[*].configuration_recorder)
    "cn-north-1"      = one(module.config_baseline_cn-north-1[*].configuration_recorder)
  }
}

output "config_sns_topic" {
  description = "The SNS topic) that AWS Config delivers notifications to."

  value = {
    "cn-northwest-1"      = one(module.config_baseline_cn-northwest-1[*].config_sns_topic)
    "cn-north-1"      = one(module.config_baseline_cn-north-1[*].config_sns_topic)
  }
}

# --------------------------------------------------------------------------------------------------
# Outputs from guardduty-baseline module.
# --------------------------------------------------------------------------------------------------

output "guardduty_detector" {
  description = "The GuardDuty detector in each region."

  value = {
    "cn-northwest-1"      = one(module.guardduty_baseline_cn-northwest-1[*].guardduty_detector)
    "cn-north-1"      = one(module.guardduty_baseline_cn-north-1[*].guardduty_detector)
  }
}

# --------------------------------------------------------------------------------------------------
# Outputs from iam-baseline module.
# --------------------------------------------------------------------------------------------------

output "support_iam_role" {
  description = "The IAM role used for the support user."
  value       = one(module.iam_baseline[*].support_iam_role)
}

# --------------------------------------------------------------------------------------------------
# Outputs from vpc-baseline module.
# --------------------------------------------------------------------------------------------------

output "vpc_flow_logs_iam_role" {
  description = "The IAM role used for delivering VPC Flow Logs to CloudWatch Logs."
  value       = local.flow_logs_to_cw_logs ? aws_iam_role.flow_logs_publisher : null
}

output "vpc_flow_logs_group" {
  description = "The CloudWatch Logs log group which stores VPC Flow Logs in each region."

  value = local.flow_logs_to_cw_logs ? {
    "cn-northwest-1"      = one(module.vpc_baseline_cn-northwest-1[*].vpc_flow_logs_group)
    "cn-north-1"      = one(module.vpc_baseline_cn-north-1[*].vpc_flow_logs_group)
  } : null
}

output "default_vpc" {
  description = "The default VPC."

  value = {
    "cn-northwest-1"      = one(module.vpc_baseline_cn-northwest-1[*].default_vpc)
    "cn-north-1"      = one(module.vpc_baseline_cn-north-1[*].default_vpc)
  }
}

output "default_security_group" {
  description = "The ID of the default security group."

  value = {
    "cn-northwest-1"      = one(module.vpc_baseline_cn-northwest-1[*].default_security_group)
    "cn-north-1"      = one(module.vpc_baseline_cn-north-1[*].default_security_group)
  }
}

output "default_network_acl" {
  description = "The default network ACL."

  value = {
    "cn-northwest-1"      = one(module.vpc_baseline_cn-northwest-1[*].default_network_acl)
    "cn-north-1"      = one(module.vpc_baseline_cn-north-1[*].default_network_acl)
  }
}

output "default_route_table" {
  description = "The default route table."

  value = {
    "cn-northwest-1"      = one(module.vpc_baseline_cn-northwest-1[*].default_route_table)
    "cn-north-1"      = one(module.vpc_baseline_cn-north-1[*].default_route_table)
  }
}

