provider "azurerm" {
  subscription_id = var.subscription_id

  # Use Microsoft Entra ID for supported Storage operations.
  storage_use_azuread = true

  features {}
}
