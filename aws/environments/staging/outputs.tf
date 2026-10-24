output "aws_region" {
  description = "AWS region used for deployment"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the dev VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "availability_zones" {
  description = "Availability Zones used by the network"
  value       = module.network.availability_zones
}
