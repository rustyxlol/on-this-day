output "vpc_id" {
    value = aws_vpc.main.id
}

output "subnet1_id" {
    value = aws_subnet.subnet1.id
}

output "subnet2_id" {
    value = aws_subnet.subnet2.id
}

output "instance_id" {
    value = aws_instance.ec2_instance.id
}

output "instance_ip" {
    value = aws_instance.ec2_instance.public_ip
}