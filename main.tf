terraform {
  required_version = "= 0.12.13"
}

resource aws_iam_role aws_config_role {
  name               = "${var.namespace}_aws_config_security_hub_role"
  assume_role_policy = file("${path.module}/templates/json/role.json")
}

resource aws_iam_role_policy aws_config_role_policy {
  name   = "aws_config_role_policy"
  role   = aws_iam_role.aws_config_role.name
  policy = file("${path.module}/templates/json/policy.json")
}

resource aws_config_configuration_recorder config_recorder {
  name     = "${var.namespace}_aws_config_recorder"
  role_arn = aws_iam_role.aws_config_role.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource aws_config_configuration_recorder_status config_recorder_status {
  name       = "${aws_config_configuration_recorder.config_recorder.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.security_hub_delivery_channel"]
}

resource aws_config_delivery_channel security_hub_delivery_channel {
  name           = "${var.namespace}_aws_config_delivery_channel"
  depends_on     = ["aws_config_configuration_recorder.config_recorder"]
  s3_bucket_name = "${var.bucket_name}"
}

module aws_config_bucket {
  source = "github.com/joshuarose/terraform-aws-secure-s3-bucket?ref=0.0.1"
  bucket_name = var.bucket_name
  custom_policy = templatefile("${path.module}/templates/json/bucketPolicy.json", {
    account_number = var.account_number,
    bucket_name    = var.bucket_name
  })
}

resource aws_securityhub_account security_hub {}
