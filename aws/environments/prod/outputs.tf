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

# Return the instance ID only when compute is enabled.
# Return null for these outputs until an instance is enabled.
output "compute_instance_id" {
  description = "EC2 instance ID, or null when compute is disabled"
  value       = try(module.compute[0].instance_id, null)
}

# Return the public IP only when an instance has been configured.
output "compute_public_ip" {
  description = "EC2 public IPv4 address, or null when compute is disabled"
  value       = try(module.compute[0].public_ip, null)
}

# Make the compute security group available for inspection.
output "compute_security_group_id" {
  description = "Compute security group ID, or null when compute is disabled"
  value       = try(module.compute[0].security_group_id, null)
}
