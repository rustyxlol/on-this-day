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
