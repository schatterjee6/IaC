output azurevm{
 value = azurerm_virtual_machine.vm.name
}

output nic_id{
 value = azurerm_network_interface.vm.private_ip_address
}

output nsgname{
 value = azurerm_network_security_group.vm.name
}

output "secret_value" {
  value = data.azurerm_key_vault_secret.secret.value
}