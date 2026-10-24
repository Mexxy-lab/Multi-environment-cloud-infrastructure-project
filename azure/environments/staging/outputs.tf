output "resource_group_name" {
  description = "Resource group created for this environment."
  value       = azurerm_resource_group.environment.name
}

output "virtual_network_id" {
  description = "Environment VNet resource ID."
  value       = module.network.virtual_network_id
}

output "workload_subnet_id" {
  description = "Workload subnet resource ID."
  value       = module.network.workload_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet resource ID."
  value       = module.network.private_subnet_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID, or null when NAT is disabled."
  value       = module.network.nat_gateway_id
}

output "vm_id" {
  description = "Linux VM resource ID, or null when compute is disabled."
  value       = var.enable_compute ? module.compute[0].vm_id : null
}

output "vm_name" {
  description = "Linux VM name, or null when compute is disabled."
  value       = var.enable_compute ? module.compute[0].vm_name : null
}

output "vm_private_ip_address" {
  description = "Linux VM private IP, or null when compute is disabled."
  value       = var.enable_compute ? module.compute[0].private_ip_address : null
}
