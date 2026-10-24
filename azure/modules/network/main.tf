
# Create the environment's isolated virtual network.
resource "azurerm_virtual_network" "this" {
  name                = "mctp-${var.environment}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Workload subnet for future application components.
resource "azurerm_subnet" "workload" {
  name                 = "workload"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.workload_subnet_prefix]

  # Do not provide implicit outbound internet access to this subnet.
  default_outbound_access_enabled = false
}

# Private subnet for the Linux management VM.
resource "azurerm_subnet" "private" {
  name                 = "private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefix]

  # Outbound connectivity, when needed, is provided by the optional NAT Gateway.
  default_outbound_access_enabled = false
}

# Attach an NSG to the workload subnet.
# No custom inbound allow rules are created; Azure's default inbound rules apply.
resource "azurerm_network_security_group" "workload" {
  name                = "mctp-${var.environment}-workload-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# Use a separate NSG for the private compute subnet.
resource "azurerm_network_security_group" "private" {
  name                = "mctp-${var.environment}-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Define an explicit default route for the private subnet.
# When enabled, the NAT Gateway performs outbound source NAT for this subnet.
resource "azurerm_route_table" "private" {
  name                = "mctp-${var.environment}-private-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_route" "private_default" {
  name                = "default-to-internet"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.private.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.private.id
}

# A Standard static public IP is used only by the NAT Gateway.
# It is not attached to the Linux VM and does not permit inbound SSH.
resource "azurerm_public_ip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "mctp-${var.environment}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create the optional outbound gateway for private-subnet workloads.
resource "azurerm_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  name                    = "mctp-${var.environment}-nat"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

# Associate the NAT Gateway with the private subnet when enabled.
resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  count = var.enable_nat_gateway ? 1 : 0

  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}
