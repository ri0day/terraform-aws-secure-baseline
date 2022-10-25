# --------------------------------------------------------------------------------------------------
# EBS Baseline
# --------------------------------------------------------------------------------------------------

module "ebs_baseline_cn-northwest-1" {
  count  = contains(var.target_regions, "cn-northwest-1") ? 1 : 0
  source = "./modules/ebs-baseline"

  providers = {
    aws = aws.cn-northwest-1
  }
}

module "ebs_baseline_cn-north-1" {
  count  = contains(var.target_regions, "cn-north-1") ? 1 : 0
  source = "./modules/ebs-baseline"

  providers = {
    aws = aws.cn-north-1
  }
}
