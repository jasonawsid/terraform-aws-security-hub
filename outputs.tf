output aws_cli_output {
  value = "${data.local_file.invitation_file.content}"
}
