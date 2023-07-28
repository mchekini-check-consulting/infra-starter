output "db_creds" {
  value = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

output "ec2_keyName" {
  value = aws_key_pair.instance.key_name
}