variable namespace {
  type        = string
  description = "Namespacing resources for testing"
  default     = "iot"
}

variable bucket_name {
  type        = string
  description = "The name of the s3 bucket"
}

variable account_number {
  type        = string
  description = "The AWS account ID"
}

variable master_account_number {
  type        = string
  description = "The AWS account ID associated with the account to share security hub with"
}
