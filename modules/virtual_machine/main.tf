
resource "azurerm_network_security_group" "vm" {
  name                = "${var.vmprefix}-01nsg"
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.vmprefix}-nic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


data "azurerm_key_vault" "keyv" {
  name         = "Sougatavault"
  resource_group_name = "sougata-rg"
}


data "azurerm_key_vault_secret" "secret" {
  name         = "adminpassword"
  key_vault_id = data.azurerm_key_vault.keyv.id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vmprefix
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.vm.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "myosdisk1"
    caching           = var.caching
    create_option     = var.create_option
    managed_disk_type = var.managed_disk_type
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }

  os_profile {
    computer_name  = "JumpBox"
    admin_username = "testadmin"
    admin_password = var.adminpassword
    #admin_password = data.azurerm_key_vault_secret.secret.value
  }

    os_profile_windows_config {
  }

}
