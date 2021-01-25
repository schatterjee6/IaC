output rgname_Fw{
 value = element(concat(azurerm_resource_group.rg_arm.*.name, [""]), 0)
}
output rgname_jmp{
 value = element(concat(azurerm_resource_group.rg_arm.*.name, [""]), 1)
}
output rgname_nw{
 value = element(concat(azurerm_resource_group.rg_arm.*.name, [""]), 2)
}
output rgname_web{
 value = element(concat(azurerm_resource_group.rg_arm.*.name, [""]), 3)
}