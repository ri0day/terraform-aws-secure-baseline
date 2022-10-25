# --------------------------------------------------------------------------------------------------
# SecurityHub Baseline
# --------------------------------------------------------------------------------------------------

locals {
  securityhub_master_account_id = var.master_account_id
  securityhub_member_accounts   = var.member_accounts
}

module "securityhub_baseline_cn-northwest-1" {
  count  = contains(var.target_regions, "cn-northwest-1") && var.securityhub_enabled ? 1 : 0
  source = "./modules/securityhub-baseline"

  providers = {
    aws = aws.cn-northwest-1
  }

  aggregate_findings               = var.region == "cn-northwest-1"
  enable_cis_standard              = var.securityhub_enable_cis_standard
  enable_pci_dss_standard          = var.securityhub_enable_pci_dss_standard
  enable_aws_foundational_standard = var.securityhub_enable_aws_foundational_standard
  enable_product_arns              = var.securityhub_enable_product_arns
  master_account_id                = local.securityhub_master_account_id
  member_accounts                  = local.securityhub_member_accounts
}
module "securityhub_baseline_cn-north-1" {
  count  = contains(var.target_regions, "cn-north-1") && var.securityhub_enabled ? 1 : 0
  source = "./modules/securityhub-baseline"

  providers = {
    aws = aws.cn-north-1
  }

  aggregate_findings               = var.region == "cn-north-1"
  enable_cis_standard              = var.securityhub_enable_cis_standard
  enable_pci_dss_standard          = var.securityhub_enable_pci_dss_standard
  enable_aws_foundational_standard = var.securityhub_enable_aws_foundational_standard
  enable_product_arns              = var.securityhub_enable_product_arns
  master_account_id                = local.securityhub_master_account_id
  member_accounts                  = local.securityhub_member_accounts
}
