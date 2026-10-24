# Create an independent resource group for this environment.
resource "azurerm_resource_group" "environment" {
  name     = "mctp-azure-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Build the environment's VNet, subnets, NSGs, route table, and optional NAT.
module "network" {
  source = "../../modules/network"

  resource_group_name    = azurerm_resource_group.environment.name
  location               = azurerm_resource_group.environment.location
  environment            = var.environment
  vnet_address_space     = var.vnet_address_space
  workload_subnet_prefix = var.workload_subnet_prefix
  private_subnet_prefix  = var.private_subnet_prefix
  enable_nat_gateway     = var.enable_nat_gateway
  tags                   = var.tags
}

# Deploy a private Linux VM only when explicitly enabled for this environment.
module "compute" {
  count  = var.enable_compute ? 1 : 0
  source = "../../modules/compute"

  resource_group_name  = azurerm_resource_group.environment.name
  location             = azurerm_resource_group.environment.location
  environment          = var.environment
  subnet_id            = module.network.private_subnet_id
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  vm_size              = var.vm_size
  os_disk_size_gb      = var.os_disk_size_gb
  tags                 = var.tags
}
