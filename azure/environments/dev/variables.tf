# Subscription that owns this environment's resources.
variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

# Azure deployment region.
variable "location" {
  description = "Azure region for environment resources."
  type        = string
  default     = "eastus"
}

# Used in names and tags to distinguish dev, staging, and prod.
variable "environment" {
  description = "Environment identifier."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

# Environment-specific VNet and subnet address ranges.
variable "vnet_address_space" {
  description = "CIDR ranges assigned to the environment VNet."
  type        = list(string)
}

variable "workload_subnet_prefix" {
  description = "CIDR prefix for the workload subnet."
  type        = string
}

variable "private_subnet_prefix" {
  description = "CIDR prefix for private compute resources."
  type        = string
}

# NAT is optional because the gateway and its public IP incur ongoing charges.
variable "enable_nat_gateway" {
  description = "Enable outbound internet connectivity for the private subnet."
  type        = bool
  default     = false
}

# Compute is opt-in so an environment can be validated without deploying a VM.
variable "enable_compute" {
  description = "Whether to deploy the private Linux VM."
  type        = bool
  default     = false
}

variable "admin_username" {
  description = "Linux VM administrator username."
  type        = string
  default     = "azureadmin"
}

# Supply the public key only; never put the private key in Terraform variables.
variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VM administration."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition = (
      !var.enable_compute ||
      length(trimspace(var.admin_ssh_public_key)) > 0
    )
    error_message = "Provide admin_ssh_public_key when enable_compute is true."
  }
}

variable "vm_size" {
  description = "Azure VM size when compute is enabled."
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "Linux OS disk size in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "os_disk_size_gb must be at least 30 GiB."
  }
}

# Consistent tags make costs and resources easier to identify.
variable "tags" {
  description = "Tags applied to environment resources."
  type        = map(string)
  default     = {}
}

# variable "state_container_name" {
#   description = "Private Blob container used for Terraform remote state."
#   type        = string
#   default     = "tfstate"
# }

# variable "state_resource_group_name" {
#   description = "Resource group for the Terraform state storage account."
#   type        = string
#   default     = "mctpstate-rg"
# }

