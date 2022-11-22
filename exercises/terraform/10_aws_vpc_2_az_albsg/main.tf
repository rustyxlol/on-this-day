terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "tf_subnet_pub1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-subnet-pub1"
    Type = "public"
  }
}

resource "aws_subnet" "tf_subnet_pub2" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-subnet-pub2"
    Type = "public"
  }
}

resource "aws_subnet" "tf_subnet_priv1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-subnet-priv1"
    Type = "private"
  }
}

resource "aws_subnet" "tf_subnet_priv2" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-subnet-priv2"
    Type = "private"
  }
}

# Create IGW
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create NAT
resource "aws_eip" "tf_eip" {
  vpc = true
}

resource "aws_nat_gateway" "tf_nat_gw" {
  allocation_id = aws_eip.tf_eip.id
  subnet_id     = aws_subnet.tf_subnet_pub1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.tf_igw
  ]

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}


# Create two route tables(pub and priv)
resource "aws_route_table" "tf_rt_pub" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
    Type = "public"
  }
}

resource "aws_route_table" "tf_rt_priv" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-rt-private"
    Type = "private"
  }
}

# Create RTA
resource "aws_route_table_association" "tf_rta_sub_pub1" {
  subnet_id      = aws_subnet.tf_subnet_pub1.id
  route_table_id = aws_route_table.tf_rt_pub.id
}
resource "aws_route_table_association" "tf_rta_sub_pub2" {
  subnet_id      = aws_subnet.tf_subnet_pub2.id
  route_table_id = aws_route_table.tf_rt_pub.id
}
resource "aws_route_table_association" "tf_rta_sub_priv1" {
  subnet_id      = aws_subnet.tf_subnet_priv1.id
  route_table_id = aws_route_table.tf_rt_priv.id
}
resource "aws_route_table_association" "tf_rta_sub_priv2" {
  subnet_id      = aws_subnet.tf_subnet_priv2.id
  route_table_id = aws_route_table.tf_rt_priv.id
}

# Create security groups
resource "aws_security_group" "tf_webserver_sg" {
  name        = "${var.project_name}-security-group"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20",
      "10.0.16.0/20"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-webserver-security-group"
  }
}

resource "aws_security_group" "tf_alb_sg" {
  name        = "allow_HTTP"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-allow-http"
  }
}

# Create launch template
resource "aws_launch_template" "tf_launch_template" {
  name          = "${var.project_name}-launch-template"
  image_id      = "ami-074dc0a6f6c764218"
  instance_type = "t2.micro"
  key_name      = "marketing-kp"

  vpc_security_group_ids = [aws_security_group.tf_webserver_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  user_data = filebase64("userdata.sh")

}

# Create ALB
resource "aws_lb" "tf_alb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_alb_sg.id]
  subnets            = [aws_subnet.tf_subnet_pub1.id, aws_subnet.tf_subnet_pub2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# Create ALB TG
resource "aws_alb_target_group" "tf_target_groups" {
  port        = 80
  protocol    = "HTTP"

  vpc_id      = aws_vpc.tf_vpc.id
}

# Create ALB Listeners and rules...
resource "aws_alb_listener" "tf_alb_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tf_target_groups.arn
  }
}

resource "aws_alb_listener_rule" "tf_alb_listener_rule" {
  listener_arn = aws_alb_listener.tf_alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tf_target_groups.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Create ASG
resource "aws_autoscaling_group" "tf_asg" {
  vpc_zone_identifier = [aws_subnet.tf_subnet_priv1.id, aws_subnet.tf_subnet_priv2.id]

  desired_capacity = 1
  min_size         = 1
  max_size         = 3

  target_group_arns = [aws_alb_target_group.tf_target_groups.arn]
  launch_template {
    id      = aws_launch_template.tf_launch_template.id
    version = "$Latest"
  }
}
