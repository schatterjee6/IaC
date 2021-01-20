resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  location            = var.location
  resource_group_name = var.networkrg
  address_space       = var.address_space
  dns_servers         = []
}