terraform {
  backend "azurerm" {
    #subscription_id      = "f36cd87f-b802-475d-8d64-54466c2c12cc"
    resource_group_name  = "sougata-rg"
    storage_account_name = "sougata"
    container_name       = "tfstate"
    key                  = "devops.tfstate"
  }
}
