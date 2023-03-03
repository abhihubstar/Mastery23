output "id" {
  value = aws_autoscaling_group.this.id
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "fqdn" {
  value = aws_route53_record.route53.fqdn
}
