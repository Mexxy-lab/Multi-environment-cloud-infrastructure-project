# Use the active Azure CLI identity and the selected subscription.
provider "azurerm" {
  subscription_id     = var.subscription_id
  storage_use_azuread = true

  # Required AzureRM provider configuration.
  features {}
}