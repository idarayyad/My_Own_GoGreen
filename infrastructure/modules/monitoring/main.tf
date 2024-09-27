# Monitoring Module for Go Green Insurance

# Variables
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "web_asg_name" {
  description = "The name of the Web tier Auto Scaling Group"
  type        = string
}

variable "app_asg_name" {
  description = "The name of the App tier Auto Scaling Group"
  type        = string
}

variable "db_instance_id" {
  description = "The instance ID of the RDS database"
  type        = string
}

variable "alarm_email" {
  description = "Email address to notify for alarms"
  type        = string
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name = "go-green-alarms-topic"
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Alarms

# Web Tier CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu" {
  alarm_name          = "go-green-web-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors web tier EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
}

# App Tier CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "app_cpu" {
  alarm_name          = "go-green-app-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors app tier EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }
}

# Database CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "go-green-db-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors database CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

# Database Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "db_storage" {
  alarm_name          = "go-green-db-storage-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000000000"  # 5 GB in bytes
  alarm_description   = "This metric monitors free storage space in the database"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Go-Green-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.web_asg_name],
            [".", ".", "AutoScalingGroupName", var.app_asg_name],
            ["AWS/RDS", ".", "DBInstanceIdentifier", var.db_instance_id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-west-2"
          title   = "CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_instance_id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-west-2"
          title   = "RDS Free Storage Space"
        }
      }
    ]
  })
}

# Outputs
output "alarm_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_name" {
  description = "The name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}