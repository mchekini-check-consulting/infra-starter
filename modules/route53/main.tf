data "aws_route53_zone" "selected" {
  name         = var.hostedZone
  private_zone = false
}

resource "aws_route53_record" "www" {
  count = length(var.applications)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.applications[count.index].dnsPrefix}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = var.alb-dns-name
    zone_id                = var.alb-zone-id
  }
}