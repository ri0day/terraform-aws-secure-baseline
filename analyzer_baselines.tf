locals {
  is_analyzer_enabled = var.analyzer_baseline_enabled && (local.is_individual_account || local.is_master_account)
}

# --------------------------------------------------------------------------------------------------
# Analyzer Baseline
# --------------------------------------------------------------------------------------------------

module "analyzer_baseline_cn-northwest-1" {
  count  = local.is_analyzer_enabled && contains(var.target_regions, "cn-northwest-1") ? 1 : 0
  source = "./modules/analyzer-baseline"

  providers = {
    aws = aws.cn-northwest-1
  }

  analyzer_name   = var.analyzer_name
  is_organization = local.is_master_account

  tags = var.tags
}
module "analyzer_baseline_cn-north-1" {
  count  = local.is_analyzer_enabled && contains(var.target_regions, "cn-north-1") ? 1 : 0
  source = "./modules/analyzer-baseline"

  providers = {
    aws = aws.cn-north-1
  }

  analyzer_name   = var.analyzer_name
  is_organization = local.is_master_account

  tags = var.tags
}
