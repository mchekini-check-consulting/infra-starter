data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "db-security-group" {
  vpc_id      = data.aws_vpc.default.id
  name        = "ec2-security-group"
  description = "Allow all inbound for EC2 Instance"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ec2-instance" {
  count           = length(var.ec2-instances)
  ami             = "ami-024e6efaf93d85776"
  instance_type   = var.ec2-instances[count.index].type
  subnet_id       = var.ec2-instances[count.index].subnet
  security_groups = [aws_security_group.db-security-group.name]
  user_data       = templatefile("./scripts/init.tftpl", { instanceNumber = count.index })
  key_name        = var.ec2_keyName

  root_block_device {
    volume_size = var.ec2-instances[count.index].volumeSize
  }

  tags = {
    Name = "test-vm-${count.index}"
  }
}


resource "aws_lb" "sm-lb" {
  count              = length(var.ec2-instances) > 1 ? 1 : 0
  name               = "sm-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.db-security-group.id]
  subnets            = [for sid in var.ec2-instances : sid.subnet]
}

resource "aws_lb_target_group" "sm-tg" {
  count       = length(var.applications) > 1 ? length(var.applications) : 0
  name        = "sm-tg-${var.applications[count.index].name}"
  port        = var.applications[count.index].port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id
}


resource "aws_lb_target_group_attachment" "sm-tg-attachment" {
  count            = length(var.ec2-instances) > 1 ? length(var.ec2-instances) : 0
  target_group_arn = aws_lb_target_group.sm-tg[0].arn
  target_id        = aws_instance.ec2-instance[count.index].id
}

resource "aws_lb_target_group_attachment" "sm-tg-attachment-1" {
  count            = length(var.ec2-instances) > 1 ? length(var.ec2-instances) : 0
  target_group_arn = aws_lb_target_group.sm-tg[1].arn
  target_id        = aws_instance.ec2-instance[count.index].id
}

resource "aws_lb_listener" "sm-listner" {
  count             = length(var.ec2-instances) > 1 ? 1 : 0
  load_balancer_arn = aws_lb.sm-lb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sm-tg[0].arn
  }

}



resource "aws_lb_listener_rule" "rule" {

  count = length(var.applications) > 1 ? length(var.applications) : 0

  listener_arn = aws_lb_listener.sm-listner[0].arn
  priority     = 100 + count.index

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sm-tg[count.index].arn
  }

  condition {
    host_header {
      values = ["${var.applications[count.index].dnsPrefix}.${var.hostedZone}" ]
    }
  }
}