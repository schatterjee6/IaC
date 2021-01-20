terraform {
  backend "azurerm" {
    resource_group_name  = "sougata-rg"
    storage_account_name = "sougata"
    container_name       = "tfstate"
    key                  = "newpoocterraform.tfstate"
  }
}
