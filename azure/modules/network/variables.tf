
# The environment root owns the resource group; the module creates networking in it.
variable "resource_group_name" {
  description = "Resource group for this environment's network."
  type        = string
}

variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
}

# Use non-overlapping address ranges for dev, staging, and prod.
variable "vnet_address_space" {
  description = "CIDR range assigned to the environment virtual network."
  type        = list(string)
}

variable "workload_subnet_prefix" {
  description = "CIDR range for the workload subnet."
  type        = string
}

variable "private_subnet_prefix" {
  description = "CIDR range for private compute resources."
  type        = string
}

# NAT Gateway enables outbound internet connectivity for private resources.
# It is optional because NAT Gateway and its public IP incur ongoing charges.
variable "enable_nat_gateway" {
  description = "Whether to create and attach a NAT Gateway to the private subnet."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
