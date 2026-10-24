# This module creates a Linux VM and NIC in the private subnet. It deliberately creates no VM public IP and opens no inbound SSH ports.
# Create a private NIC without a public IP address.
resource "azurerm_network_interface" "this" {
  name                = "mctp-${var.environment}-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "private"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Deploy Ubuntu Server 22.04 with SSH-key-only authentication.
resource "azurerm_linux_virtual_machine" "this" {
  name                = "mctp-${var.environment}-vm"
  computer_name       = "mctp-${var.environment}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  # Enable Trusted Launch security features where supported by the VM size/image.
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Enable host-level encryption in addition to Azure managed-disk encryption at rest.
  encryption_at_host_enabled = true

  os_disk {
    name                 = "mctp-${var.environment}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  # Pin the OS family while allowing the image publisher to provide the latest version.
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Managed identity supports future integrations with Azure management services.
  identity {
    type = "SystemAssigned"
  }

  # Use Azure-managed boot diagnostics storage rather than a custom storage account.
  boot_diagnostics {}

  tags = var.tags
}
