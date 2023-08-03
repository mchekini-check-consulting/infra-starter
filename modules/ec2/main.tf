#data "aws_vpc" "default" {
#  id = "vpc-4cc9de24"
#}

resource "aws_security_group" "instance-security-group" {
  #  vpc_id      = data.aws_vpc.default.id
  name        = "${var.environment}-instance-security-group"
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

resource "aws_security_group" "alb-security-group" {
  #  vpc_id      = data.aws_vpc.default.id
  name        = "${var.environment}-alb-security-group"
  description = "Allow all inbound for Application Load Balancer"
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
  count                  = length(var.ec2-instances)
  ami                    = "ami-024e6efaf93d85776"
  instance_type          = var.ec2-instances[count.index].type
  subnet_id              = var.ec2-instances[count.index].subnet
  vpc_security_group_ids = [aws_security_group.instance-security-group.id]
  user_data              = templatefile("./scripts/init.tftpl", { instanceNumber = count.index })
  key_name               = var.ec2_keyName

  root_block_device {
    volume_size = var.ec2-instances[count.index].volumeSize
  }

  iam_instance_profile = var.instance-profile-name

  tags = {
    Name = "${var.environment}-sm-${count.index}"
  }
}


resource "aws_lb" "sm-lb" {
  count              = length(var.ec2-instances) > 1 ? 1 : 0
  name               = "${var.environment}-sm-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb-security-group.id]
  subnets            = [for sid in var.ec2-instances : sid.subnet]
}

resource "aws_lb_target_group" "sm-tg" {
  count       = length(var.applications) > 1 ? length(var.applications) : 0
  name        = "${var.environment}-sm-tg-${var.applications[count.index].name}"
  port        = var.applications[count.index].port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
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
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sm-tg[0].arn
  }

}

resource "aws_lb_listener" "sm-listener-redirect" {
  load_balancer_arn = aws_lb.sm-lb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
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
      values = ["${var.applications[count.index].dnsPrefix}.${var.hostedZone}"]
    }
  }
}