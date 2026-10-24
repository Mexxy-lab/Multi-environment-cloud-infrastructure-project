# Store staging environment state in the private Azure Blob container.
# terraform {
#   backend "azurerm" {
#     resource_group_name  = ""
#     storage_account_name = ""
#     container_name       = ""
#     key                  = "azure/staging/terraform.tfstate"

#     # Authenticate using the existing Azure CLI identity and Microsoft Entra ID.
#     use_cli          = true
#     use_azuread_auth = true
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}