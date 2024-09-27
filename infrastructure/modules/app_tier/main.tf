# App Tier Module for Go Green Insurance

# Variables
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the app servers"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "The minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the ASG"
  type        = number
  default     = 4
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for App Servers
resource "aws_security_group" "app" {
  name        = "go-green-app-sg"
  description = "Security group for app servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "go-green-app-sg"
  }
}

# Launch Template for App Servers
resource "aws_launch_template" "app" {
  name_prefix   = "go-green-app-"
  instance_type = var.instance_type
  image_id      = data.aws_ami.amazon_linux_2.id

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Go Green App Server" > index.html
              nohup python -m SimpleHTTPServer 8080 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "go-green-app-server"
    }
  }
}

# Auto Scaling Group for App Servers
resource "aws_autoscaling_group" "app" {
  name                = "go-green-app-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "go-green-app-server"
    propagate_at_launch = true
  }
}

# Outputs
output "app_sg_id" {
  description = "The ID of the app server security group"
  value       = aws_security_group.app.id
}

output "asg_name" {
  description = "The name of the app server Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}