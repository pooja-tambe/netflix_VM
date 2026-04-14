resource "azurerm_resource_group" "RG" {
  name     = var.RG_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name               = var.container
  storage_account_id = azurerm_storage_account.storage.id

}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.RG_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend_subnet" {
  name                 = var.subent_name
  resource_group_name  = var.RG_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  resource_group_name = var.RG_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend_subnet.id
    public_ip_address_id          = azurerm_public_ip.PIP.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "PIP" {
  name                = "public_IP"
  resource_group_name = var.RG_name
  location            = var.location
  allocation_method   = "Static"
}

# create VM 

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = var.vm
  resource_group_name             = var.RG_name
  location                        = var.location
  size                            = var.size
  admin_username                  = "azureuse"
  admin_password                  = "password@1234!"
  disable_password_authentication = "false"


  network_interface_ids = [ azurerm_network_interface.nic.id ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    version   = "latest"
    sku       = "22_04-lts"
  }
}

resource "azurerm_network_security_group" "NSG" {
  name = var.nsg_name
  resource_group_name = var.RG_name
  location = var.location

  security_rule  {
    name = "SSH_allow"
    priority = "1001"
    direction = "Inbound"
    protocol = "Tcp"
    access = "Allow"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "HTTP_allow"
    priority = "1002"
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_attach" {
  network_security_group_id = azurerm_network_security_group.NSG.id
  network_interface_id = azurerm_network_interface.nic.id
}
