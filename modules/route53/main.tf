data "aws_route53_zone" "selected" {
  name         = var.hostedZone
  private_zone = false
}

resource "aws_route53_record" "app-records" {
  count   = length(var.applications)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.applications[count.index].dnsPrefix}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = var.alb-dns-name
    zone_id                = var.alb-zone-id
  }
}


resource "aws_route53_record" "ec2-instances-records" {
  count   = length(var.ec2-instances)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.environment}-vm-${count.index + 1}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = 30
  records = [var.ec2-ips[count.index]]
}