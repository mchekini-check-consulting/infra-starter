#data "aws_vpc" "default" {
#  default = true
#}

resource "aws_security_group" "db-security-group" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-postgres-security-group"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "staff-manager-db-instance" {
  identifier             = "${var.environment}-sm-db"
  db_name                = "${var.environment}_sm_db"
  instance_class         = "db.m5d.large"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db-security-group.id]
  username               = var.cred.username
  password               = var.cred.password
}