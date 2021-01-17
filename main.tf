provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-SecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-publicIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-LoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-BackEndAddressPool"
}


resource "azurerm_network_interface" "main" {
  count               = var.vmcount
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}-nic-backendpool-config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.vmcount
  network_interface_id    = azurerm_network_interface.main.*.id[count.index]
  ip_configuration_name   = "${var.prefix}-nic-backendpool-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

data "azurerm_image" "image" {
  name                = "myPackerImage"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_availability_set" "avset" {
  name                          = "${var.prefix}-availability-set"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  platform_fault_domain_count   = 2
  platform_update_domain_count  = 2
  managed                       = true

}

resource "azurerm_managed_disk" "managed_disk" {
  count                = var.vmcount
  name                 = "managed-disk-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
  count              = var.vmcount
  managed_disk_id    = azurerm_managed_disk.managed_disk.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.main.*.id[count.index]
  lun                = count.index + 10
  caching            = "ReadWrite"
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vmcount
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_V3"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd12344"
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.avset.id

  network_interface_ids = [azurerm_network_interface.main.*.id[count.index],]

  source_image_id                = data.azurerm_image.image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
