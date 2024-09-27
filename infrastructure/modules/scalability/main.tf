# Scalability Module for Go Green Insurance

# Variables
variable "web_asg_name" {
  description = "The name of the Web tier Auto Scaling Group"
  type        = string
}

variable "app_asg_name" {
  description = "The name of the App tier Auto Scaling Group"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of instances in each tier"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of instances in each tier"
  type        = number
  default     = 10
}

# Web Tier Auto Scaling Policy - Scale Out
resource "aws_autoscaling_policy" "web_scale_out" {
  name                   = "go-green-web-scale-out"
  autoscaling_group_name = var.web_asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Web Tier Auto Scaling Policy - Scale In
resource "aws_autoscaling_policy" "web_scale_in" {
  name                   = "go-green-web-scale-in"
  autoscaling_group_name = var.web_asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# App Tier Auto Scaling Policy - Scale Out
resource "aws_autoscaling_policy" "app_scale_out" {
  name                   = "go-green-app-scale-out"
  autoscaling_group_name = var.app_asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# App Tier Auto Scaling Policy - Scale In
resource "aws_autoscaling_policy" "app_scale_in" {
  name                   = "go-green-app-scale-in"
  autoscaling_group_name = var.app_asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# CloudWatch Alarm - Web Tier High CPU
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "go-green-web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric triggers when CPU utilization is above 70% for 2 consecutive periods of 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.web_scale_out.arn]
  
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
}

# CloudWatch Alarm - Web Tier Low CPU
resource "aws_cloudwatch_metric_alarm" "web_cpu_low" {
  alarm_name          = "go-green-web-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric triggers when CPU utilization is below 30% for 2 consecutive periods of 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.web_scale_in.arn]
  
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
}

# CloudWatch Alarm - App Tier High CPU
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "go-green-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric triggers when CPU utilization is above 70% for 2 consecutive periods of 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.app_scale_out.arn]
  
  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }
}

# CloudWatch Alarm - App Tier Low CPU
resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "go-green-app-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric triggers when CPU utilization is below 30% for 2 consecutive periods of 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.app_scale_in.arn]
  
  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }
}

# Scheduled Action - Increase capacity during business hours
resource "aws_autoscaling_schedule" "increase_capacity_business_hours" {
  scheduled_action_name  = "increase-capacity-business-hours"
  min_size               = var.min_capacity
  max_size               = var.max_capacity
  desired_capacity       = var.min_capacity + 2
  recurrence             = "0 9 * * MON-FRI"
  autoscaling_group_name = var.web_asg_name
}

# Scheduled Action - Decrease capacity after business hours
resource "aws_autoscaling_schedule" "decrease_capacity_after_hours" {
  scheduled_action_name  = "decrease-capacity-after-hours"
  min_size               = var.min_capacity
  max_size               = var.max_capacity
  desired_capacity       = var.min_capacity
  recurrence             = "0 18 * * MON-FRI"
  autoscaling_group_name = var.web_asg_name
}

# Outputs
output "web_scale_out_policy_arn" {
  description = "ARN of the web tier scale out policy"
  value       = aws_autoscaling_policy.web_scale_out.arn
}

output "app_scale_out_policy_arn" {
  description = "ARN of the app tier scale out policy"
  value       = aws_autoscaling_policy.app_scale_out.arn
}