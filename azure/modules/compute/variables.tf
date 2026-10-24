
# Environment-specific inputs supplied by the calling Terraform root.
variable "resource_group_name" {
  description = "Resource group containing the Linux VM."
  type        = string
}

variable "location" {
  description = "Azure region for the Linux VM."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
}

variable "subnet_id" {
  description = "ID of the private subnet where the VM NIC will be placed."
  type        = string
}

# Use SSH key authentication instead of an administrator password.
variable "admin_username" {
  description = "Linux administrator username."
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "Contents of the administrator's SSH public key."
  type        = string
  sensitive   = true
}

# Keep VM size and disk size configurable for cost and quota management.
variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "OS disk capacity in GiB."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to compute resources."
  type        = map(string)
  default     = {}
}
