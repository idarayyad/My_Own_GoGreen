# Data Tier Module for Go Green Insurance

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
  description = "The instance type for the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "gogreen"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
}

# Security Group for RDS
resource "aws_security_group" "db" {
  name        = "go-green-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL traffic from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "go-green-db-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "go-green-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "Go Green DB subnet group"
  }
}

# RDS Instance
resource "aws_db_instance" "default" {
  identifier           = "go-green-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.instance_type
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  multi_az               = true
  backup_retention_period = 7
  skip_final_snapshot    = true

  tags = {
    Name = "Go Green RDS Instance"
  }
}

# Outputs
output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.default.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.default.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.default.username
  sensitive   = true
}