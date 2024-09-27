# Variables for the main Terraform configuration

variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-west-2"  # Change this to your preferred region
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "web_instance_type" {
  description = "The instance type for web servers"
  default     = "t3.medium"
}

variable "web_min_size" {
  description = "The minimum number of web servers"
  default     = 2
}

variable "web_max_size" {
  description = "The maximum number of web servers"
  default     = 4
}

variable "app_instance_type" {
  description = "The instance type for application servers"
  default     = "t3.medium"
}

variable "app_min_size" {
  description = "The minimum number of application servers"
  default     = 2
}

variable "app_max_size" {
  description = "The maximum number of application servers"
  default     = 4
}

variable "db_instance_type" {
  description = "The instance type for the database"
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "The name of the database"
  default     = "gogreen_db"
}

variable "db_username" {
  description = "The username for the database"
}

variable "db_password" {
  description = "The password for the database"
}