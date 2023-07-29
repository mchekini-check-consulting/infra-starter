output "dns-name" {
  value = aws_lb.sm-lb[0].dns_name
}

output "zone-id" {
  value = aws_lb.sm-lb[0].zone_id
}

output "ec2-ips" {
  value = [for instance in aws_instance.ec2-instance : instance.public_ip ]
}