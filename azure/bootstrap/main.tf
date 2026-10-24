
# Create a dedicated resource group for Terraform remote state.
resource "azurerm_resource_group" "state" {
  name     = "mctp-tfstate-rg"
  location = var.location

  tags = {
    project    = "multi-cloud-terraform-platform"
    purpose    = "terraform-remote-state"
    managed_by = "terraform"
  }
}

# Create a private, encrypted Storage Account for Terraform state.
resource "azurerm_storage_account" "state" {
  name                = var.state_storage_account_name
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Require secure transport and prevent anonymous blob access.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # Protect state files against accidental overwrites and deletions.
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  # Prevent Terraform from accidentally destroying the state account.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    project     = "multi-cloud-terraform-platform"
    environment = "shared"
    managed_by  = "terraform"
  }
}

# Create the private Blob container that will hold all Azure environment states.
resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

# Identify the Azure user or service principal running this Terraform deployment.
# This avoids hardcoding a personal account ID or storing credentials in the code.
data "azurerm_client_config" "current" {}

# Grant the deployment identity permission to read, write, and lock Terraform
# state blobs. Scope the role to the state container rather than the subscription.
resource "azurerm_role_assignment" "state_blob_access" {
  scope                = azurerm_storage_container.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id

  description = "Allow the Terraform deployment identity to manage remote state blobs."
}
