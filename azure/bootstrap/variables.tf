
# Azure subscription where the state resources will be created.
variable "subscription_id" {
  description = "Azure subscription ID for the bootstrap deployment."
  type        = string
}

# Globally unique Storage Account name: 3–24 lowercase letters or numbers.
variable "state_storage_account_name" {
  description = "Globally unique Azure Storage Account name for Terraform state."
  type        = string

  validation {
    condition = (
      length(var.state_storage_account_name) >= 3 &&
      length(var.state_storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.state_storage_account_name))
    )
    error_message = "The Storage Account name must contain 3–24 lowercase letters or numbers."
  }
}

# Container used by the Azure dev, staging, and prod Terraform backends.
variable "state_container_name" {
  description = "Private Blob container used for Terraform remote state."
  type        = string
  default     = "tfstate"
}

# Azure region for the shared state resources.
variable "location" {
  description = "Azure region for the Terraform state resource group."
  type        = string
  default     = "eastus"
}
