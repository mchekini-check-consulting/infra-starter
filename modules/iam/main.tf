resource "aws_iam_role" "sm-role" {
  name = "${var.environment}-sm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "secret-manager-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role      = aws_iam_role.sm-role.name
}

resource "aws_iam_role_policy_attachment" "s3-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.sm-role.name
}

resource "aws_iam_instance_profile" "secret-manager-instance-profile" {
  name = "${var.environment}-secret-manager-instance-profile"
  role = aws_iam_role.sm-role.name
}