variable "audit_s3_bucket_name" {
  description = "The name of the S3 bucket to store various audit logs."
  type        = string
}

variable "default_region" {
  description = "The AWS region in which global resources are set up."
  type        = string
  default     = "cn-northwest-1"
}
variable "account_id" {
    type = string
  }

variable "support_users" {
  type = list(string)
}
variable "target_regions" {
  type = list(string)
}
