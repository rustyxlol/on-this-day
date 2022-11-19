terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "exercise-1-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/20"

  availability_zone = "ap-south-1a"
  tags = {
    Name = "exercise-1-public-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/20"

  availability_zone = "ap-south-1b"
  tags = {
    Name = "exercise-1-public-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "exercise-1-igw"
  }
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "exercise-1-route-table"
  }
}

resource "aws_route_table_association" "rta_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_default_route_table.rt.id
}

resource "aws_route_table_association" "rta_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_default_route_table.rt.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_HTTP"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_sg"
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-074dc0a6f6c764218"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  associate_public_ip_address = true

  user_data = <<-EOL
  #!/bin/bash -xe

  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  EOL
  tags = {
    Name = "exercise-1-ec2"
  }
}