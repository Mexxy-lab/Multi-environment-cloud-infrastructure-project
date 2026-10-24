
# Export the names required by the Azure Blob remote-state backend.
output "state_storage_account_name" {
  description = "Storage Account containing Terraform state."
  value       = azurerm_storage_account.state.name
}

output "state_resource_group_name" {
  description = "Resource group containing the state Storage Account."
  value       = azurerm_resource_group.state.name
}

output "state_container_name" {
  description = "Private Blob container used for Terraform state."
  value       = azurerm_storage_container.tfstate.name
}

# Useful for verifying the scope of the granted data-access role.
output "state_container_id" {
  description = "Azure resource ID of the Terraform state container."
  value       = azurerm_storage_container.tfstate.id
}

output "state_deployment_principal_id" {
  description = "Object ID of the identity running the bootstrap."
  value       = data.azurerm_client_config.current.object_id
}
