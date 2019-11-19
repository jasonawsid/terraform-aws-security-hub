terraform {
  required_version = "= 0.12.13"
}

resource aws_config_configuration_recorder config_recorder {
  name     = "${var.namespace}_aws_config_recorder"
  role_arn = "arn:aws:iam::${var.account_number}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
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
  source      = "github.com/pgalchemy/terraform-aws-secure-s3-bucket?ref=0.0.1"
  bucket_name = var.bucket_name
  custom_policy = templatefile("${path.module}/templates/json/bucketPolicy.json", {
    account_number = var.account_number,
    bucket_name    = var.bucket_name
  })
}

resource aws_securityhub_account security_hub {}

data template_file invitation_template {
  template = "${path.module}/invitation.txt"
}

data local_file invitation_file {
  filename = "${data.template_file.invitation_template.rendered}"
  depends_on = [
    null_resource.invitation_id,
    data.template_file.invitation_template
  ]
}

resource null_resource invitation_id {
  provisioner "local-exec" {
    command = "aws securityhub list-invitations --region=us-east-1 --output text --query 'Invitations[*].[InvitationId]' > ${data.template_file.invitation_template.rendered}"
  }
}

resource null_resource invitation_accepter {
  provisioner "local-exec" {
    command = "aws securityhub accept-invitation --region=us-east-1 --master-id=${var.master_account_number} --invitation-id=${data.local_file.invitation_file.content}"
  }

  depends_on = [
    data.local_file.invitation_file
  ]
}
