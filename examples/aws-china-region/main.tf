provider "aws" {
  region = "cn-north-1"
  alias  = "cn-north-1"
}

provider "aws" {
  region = "cn-northwest-1"
  alias  = "cn-northwest-1"
}
provider "aws" {
    region = "cn-northwest-1"
  }

module "secure_baseline" {
  source = "/Users/min/repos/foxhis-gms/local-modules/secure-baseline-cn"
  audit_log_bucket_name           = var.audit_s3_bucket_name
  aws_account_id                  = var.account_id
  region                          = var.default_region
  support_iam_role_principal_arns = var.support_users
  target_regions                  = var.target_regions

  audit_log_bucket_force_destroy = true
  providers = {
    aws                = aws
    aws.cn-northwest-1      = aws.cn-northwest-1
    aws.cn-north-1      = aws.cn-north-1
  }
}
