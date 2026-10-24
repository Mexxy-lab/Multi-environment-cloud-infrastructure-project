
# Export values useful for validation and Azure management tooling.
output "vm_id" {
  description = "Resource ID of the Linux VM."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the Linux VM."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP address assigned to the VM."
  value       = azurerm_linux_virtual_machine.this.private_ip_address
}

output "network_interface_id" {
  description = "Resource ID of the VM network interface."
  value       = azurerm_network_interface.this.id
}

output "managed_identity_principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
}
