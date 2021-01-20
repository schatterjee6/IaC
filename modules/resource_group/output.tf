output rgname_Fw{
 value = element(concat(azurerm_resource_group.arm_rg.*.name, [""]), 0)
}
output rgname_jmp{
 value = element(concat(azurerm_resource_group.arm_rg.*.name, [""]), 1)
}
output rgname_nw{
 value = element(concat(azurerm_resource_group.arm_rg.*.name, [""]), 2)
}
output rgname_web{
 value = element(concat(azurerm_resource_group.arm_rg.*.name, [""]), 3)
}