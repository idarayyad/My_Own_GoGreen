# Main Terraform configuration for Go Green Insurance AWS Infrastructure

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Web Tier Module
module "web_tier" {
  source = "./modules/web_tier"
  vpc_id = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  instance_type = var.web_instance_type
  min_size = var.web_min_size
  max_size = var.web_max_size
}

# App Tier Module
module "app_tier" {
  source = "./modules/app_tier"
  vpc_id = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  instance_type = var.app_instance_type
  min_size = var.app_min_size
  max_size = var.app_max_size
}

# Data Tier Module
module "data_tier" {
  source = "./modules/data_tier"
  vpc_id = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  instance_type = var.db_instance_type
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

# Security Module
module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  vpc_id = module.networking.vpc_id
}

# Scalability Module
module "scalability" {
  source = "./modules/scalability"
  web_asg_name = module.web_tier.asg_name
  app_asg_name = module.app_tier.asg_name
}