terraform {
  required_version = "= 0.12.13"
}

provider aws {
  region  = "us-east-1"
  version = "= 2.35.0"
}

provider random {
  version = "~> 2.1"
}

module security_hub {
  source                = "../../"
  namespace             = "terratest"
  bucket_name           = "terratest-aws-config-testing-bucket-josh"
  account_number        = "REPLACEME"
  master_account_number = "REPLACEME"
}
