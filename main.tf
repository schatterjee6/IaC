provider "azurerm" {
  version = "=2.33.0"
  features {}
}

/* Source the module example resource group and below variables ie resource_group_name, loction are the variables 
declared under {modules/resourcegroup}. The values ie var.rg_name needs to be declared on tfvars*/
module "resource_group" {
  source          = "./modules/resource_group"
  resource_group_name  = var.rg_arm
  location        = var.location
}


/*
resource "azurerm_resource_group" "Fw-RG" {
  name     = "Fw-RG"
  location = var.location
}

resource "azurerm_resource_group" "Jmp-RG" {
  name     = "Jmp-RG"
  location = var.location
}

resource "azurerm_resource_group" "Network-RG" {
  name     = "Network-RG"
  location = var.location
}

resource "azurerm_resource_group" "Web-RG" {
  name     = "Web-RG"
  location = var.location
}*/

resource "azurerm_network_security_group" "nsgjmp" {
  name                = var.jmpnsg
  location            = var.location
  resource_group_name = module.resource_group.rgname_jmp #THis is captured fom output.tf under modules, resourcegroup
}

resource "azurerm_network_security_rule" "nsgjmprule" {
  name                        = "nsgjmprule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.rgname_jmp
  network_security_group_name = azurerm_network_security_group.nsgjmp.name
}

module "shared-vnet" {
 source = "./modules/vnet"
 vnetname = var.sharedvnet
 location = var.location
 networkrg = module.resource_group.rgname_nw
 address_space = var.sharedspace

/*
resource "azurerm_virtual_network" "SharedVnet" {
  name                = "Shared-Vnet"
  location            = azurerm_resource_group.Network-RG.location
  resource_group_name = azurerm_resource_group.Network-RG.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []
*/
}
   resource "azurerm_subnet" "Firewall" {
   name                 = "AzureFirewallSubnet"
   resource_group_name  = module.resource_group.rgname_nw
   virtual_network_name = module.shared-vnet.vnet_name
   address_prefixes     = ["10.0.1.0/24"]
  }

  resource "azurerm_subnet" "Bastion" {
   name                 = "Bastion-Subnet"
   resource_group_name  = module.resource_group.rgname_nw
   virtual_network_name = module.shared-vnet.vnet_name
   address_prefixes     = ["10.0.2.0/24"]
  }


resource "azurerm_network_security_group" "nsgapplciation" {
  name                = var.appnsg
  location            = var.location
  resource_group_name = module.resource_group.rgname_web
}

resource "azurerm_network_security_rule" "nsgwebrule" {
  name                        = "nsgwebrule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.rgname_web
  network_security_group_name = azurerm_network_security_group.nsgapplciation.name
}


module "App-vnet" {
 source = "./modules/vnet"
 vnetname = var.appvnet
 location = var.location
 networkrg = module.resource_group.rgname_nw
 address_space = var.sharedspaceapp
}

/*
resource "azurerm_virtual_network" "AppVnet" {
  name                = "Application-Vnet"
  location            = azurerm_resource_group.Network-RG.location
  resource_group_name = azurerm_resource_group.Network-RG.name
  address_space       = ["192.168.0.0/16"]
  dns_servers         = []
}*/

  resource "azurerm_subnet" "Tier1" {
   name                 = "Tier1-subnet"
   resource_group_name  = module.resource_group.rgname_nw
   virtual_network_name = module.App-vnet.vnet_name
   address_prefixes     = ["192.168.0.0/24"]
  }

resource "azurerm_virtual_network_peering" "SharedVnet-AppVnet" {
  name                      = "SharedVnettoAppVnet"
  resource_group_name       = module.resource_group.rgname_nw
  virtual_network_name      = module.shared-vnet.vnet_name
  remote_virtual_network_id = module.App-vnet.vnet_id
}


resource "azurerm_virtual_network_peering" "AppVnet-SharedVnet" {
  name                      = "AppVnettoSharedVnet"
  resource_group_name       = module.resource_group.rgname_nw
  virtual_network_name      = module.App-vnet.vnet_name
  remote_virtual_network_id = module.shared-vnet.vnet_id
}

resource "azurerm_public_ip" "Fwpip" {
  name                = "Firewall-Sou-Pip"
  location            = var.location
  resource_group_name = module.resource_group.rgname_nw
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "Fwpip1" {
  name                = "Firewall-Sou-Pip-1"
  location            = var.location
  resource_group_name = module.resource_group.rgname_nw
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "Fw" {
  name                = "SC-IND-FW01"
  location            = var.location
  resource_group_name = module.resource_group.rgname_nw

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Firewall.id
    public_ip_address_id = azurerm_public_ip.Fwpip.id
  }
}

resource "azurerm_firewall_policy" "FWPolicy" {
  name                = "Firewall-Policy"
  resource_group_name = module.resource_group.rgname_Fw
  location            = var.location
}

module "jbox-vm" {
  source = "./modules/virtual_machine"
  vmprefix = var.jmp-vmprefix
  location = var.location
  subnet_id = azurerm_subnet.Bastion.id
  rg = var.rg
  vm_size = var.vm_size
  caching = var.caching
  create_option = var.create_option
  managed_disk_type = var.managed_disk_type
  publisher = var.publisher
  offer = var.offer
  sku = var.sku
  adminpassword = var.admin_password
  
}

module "web-vm" {
  source = "./modules/virtual_machine"
  vmprefix = var.web-vmprefix
  location = var.location
  subnet_id = azurerm_subnet.Bastion.id
  rg = var.rg1
  vm_size = var.vm_size
  caching = var.caching
  create_option = var.create_option
  managed_disk_type = var.managed_disk_type
  publisher = var.publisher
  offer = var.offer
  sku = var.sku
  adminpassword = var.admin_password
}


/*
resource "azurerm_network_interface" "nic" {
  name                = "jmp-nic"
  location            = azurerm_resource_group.Web-RG.location
  resource_group_name = azurerm_resource_group.Web-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Bastion.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_virtual_machine" "jmp" {
  name                  =  "${var.vmprefix}-ALMS01"
  location              = azurerm_resource_group.Jmp-RG.location
  resource_group_name   = azurerm_resource_group.Jmp-RG.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "JumpBox"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

    os_profile_windows_config {
  }

}*/

/*
resource "azurerm_network_interface" "nic1" {
  name                = "web-nic"
  location            = azurerm_resource_group.Web-RG.location
  resource_group_name = azurerm_resource_group.Web-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Tier1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "web" {
  name                  = "web-vm"
  location              = azurerm_resource_group.Web-RG.location
  resource_group_name   = azurerm_resource_group.Web-RG.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "webserver"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
  }
}*/

resource "azurerm_firewall_nat_rule_collection" "NATrule" {
  name                = "NAT-Rule-RDP"
  azure_firewall_name = azurerm_firewall.Fw.name
  resource_group_name = module.resource_group.rgname_nw
  priority            = 100
  action              = "Dnat"

  rule {
    name = "RDPrule"

    source_addresses = [
      "*"
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      azurerm_public_ip.Fwpip.ip_address
    ]

    translated_port = 3389

    translated_address = module.jbox-vm.nic_id

    protocols = [
      "TCP",
      "UDP",
    ]
  }
    rule {
    name = "Webrule"

    source_addresses = [
      "*"
    ]

    destination_ports = [
      "80",
    ]

    destination_addresses = [
      azurerm_public_ip.Fwpip1.ip_address
    ]

    translated_port = 80

    translated_address = module.web-vm.nic_id

    protocols = [
      "TCP",
    ]
  }
  
}
