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
  source = "../../"
  audit_log_bucket_name           = "demobucket-ioyz9"
  aws_account_id                  = "123456789012"
  region                          = "cn-northwest-1"
  support_iam_role_principal_arns = "arn:aws-cn:iam::123456789012:user/user1"
  target_regions                  = ["cn-northwest-1","cn-north-1"]

  audit_log_bucket_force_destroy = true
  providers = {
    aws                = aws
    aws.cn-northwest-1      = aws.cn-northwest-1
    aws.cn-north-1      = aws.cn-north-1
  }
}
