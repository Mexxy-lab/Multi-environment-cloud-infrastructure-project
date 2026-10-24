
# Export network IDs for the compute module and future application modules.
output "virtual_network_id" {
  description = "ID of the environment virtual network."
  value       = azurerm_virtual_network.this.id
}

output "workload_subnet_id" {
  description = "ID of the workload subnet."
  value       = azurerm_subnet.workload.id
}

output "private_subnet_id" {
  description = "ID of the private compute subnet."
  value       = azurerm_subnet.private.id
}

output "workload_nsg_id" {
  description = "ID of the workload subnet NSG."
  value       = azurerm_network_security_group.workload.id
}

output "private_nsg_id" {
  description = "ID of the private subnet NSG."
  value       = azurerm_network_security_group.private.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID, or null when outbound NAT is disabled."
  value       = var.enable_nat_gateway ? azurerm_nat_gateway.this[0].id : null
}
