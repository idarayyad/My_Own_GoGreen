# Outputs for the main Terraform configuration

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "web_load_balancer_dns" {
  description = "The DNS name of the web tier load balancer"
  value       = module.web_tier.load_balancer_dns
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = module.data_tier.db_endpoint
}