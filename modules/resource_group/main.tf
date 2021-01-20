resource "azurerm_resource_group" "arm_rg" {
  count = 4
  name     = element(var.resource_group_name, count.index)
  location = var.location
}