terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2_instance" {
  count = 3
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "marketing-kp"
  
  tags = {
    Name = "exercise-11-ec2-${count.index + 1}"
  }
}