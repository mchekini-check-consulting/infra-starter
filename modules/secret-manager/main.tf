resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]"
}

resource "aws_secretsmanager_secret" "db-master-password" {
  name = "sm-${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.db-master-password.id
  secret_string = jsonencode(
    {
      "username" : "postgres",
      "password" : random_password.password.result
    }
  )
}


data "aws_secretsmanager_secret" "secretmasterDB" {
  arn = aws_secretsmanager_secret.db-master-password.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secretmasterDB.arn
}


#----------------------------------------------------------------
#                  Generate KeyPair for EC2 Instance
#----------------------------------------------------------------


resource "tls_private_key" "instance" {
  algorithm = "RSA"
}


resource "aws_key_pair" "instance" {
  key_name   = "${var.environment}-ec2-keypair"
  public_key = tls_private_key.instance.public_key_openssh
  tags       = {
    Name = "${var.environment}-ec2-keypair"
  }
}

# Creates and stores ssh key used creating an EC2 instance
resource "aws_secretsmanager_secret" "ec2-keypair" {
  name = "sm-${var.environment}-ec2-key-pair"
}


resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.ec2-keypair.id
  secret_string = tls_private_key.instance.private_key_pem
}


