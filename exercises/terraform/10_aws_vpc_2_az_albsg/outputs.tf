output "vpc_id" {
  value = aws_vpc.tf_vpc.id
}

output "public_subnet_1" {
  value = aws_subnet.tf_subnet_pub1.id
}

output "public_subnet_2" {
  value = aws_subnet.tf_subnet_pub2.id
}

output "alb_dns_name" {
  description = "alb dns"
  value       = aws_lb.tf_alb.dns_name
}