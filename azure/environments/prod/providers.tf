terraform {
  # Keep the supported Terraform CLI versions consistent with CI.
  required_version = ">= 1.9.0, < 2.0.0"


  required_providers {
    azurerm = {
      # Pin the compatible AzureRM provider release series.
      source  = "hashicorp/azurerm"
      version = "~> 4.0"

    }
  }
}

provider "azurerm" {

  subscription_id = var.subscription_id

  # Use Microsoft Entra ID for supported Storage operations.
  storage_use_azuread = true

  features {}
}
