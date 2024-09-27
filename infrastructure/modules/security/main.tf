# Security Module for Go Green Insurance

# Variables
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "web_asg_name" {
  description = "Name of the Web tier Auto Scaling Group"
  type        = string
}

variable "app_asg_name" {
  description = "Name of the App tier Auto Scaling Group"
  type        = string
}

# Web Application Firewall (WAF)
resource "aws_wafv2_web_acl" "main" {
  name  = "go-green-waf-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "go-green-waf-metric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "go-green-waf-acl-metric"
    sampled_requests_enabled   = true
  }
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "go-green-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name        = "go-green-web-sg"
  description = "Security group for web tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "go-green-app-sg"
  description = "Security group for app tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Custom TCP from web tier"
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
}

# AWS Shield Advanced
resource "aws_shield_protection" "alb" {
  name         = "go-green-alb-shield"
  resource_arn = var.alb_arn

  depends_on = [aws_shield_protection_group.web_app]
}

resource "aws_shield_protection_group" "web_app" {
  protection_group_id = "go-green-protection-group"
  aggregation         = "MAX"
  pattern             = "ALL"

  members = [var.alb_arn]
}

# GuardDuty
resource "aws_guardduty_detector" "main" {
  enable = true
}

# AWS Config
resource "aws_config_configuration_recorder" "main" {
  name     = "go-green-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config_role" {
  name = "go-green-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# KMS for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for Go Green Insurance"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Outputs
output "waf_acl_id" {
  description = "ID of the WAF ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "web_security_group_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app.id
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.main.id
}