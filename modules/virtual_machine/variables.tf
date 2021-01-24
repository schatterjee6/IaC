variable vmprefix{
    type = string
}
variable location{
    type = string
}
variable subnet_id{
    type = string
    default = "subnet_id"
} 
variable rg{
    type = string
    default = "resource_group_name"
}
variable vm_size{
    type = string
    default = "Standard_DS1_v2"
}
variable caching{
    type = string
    default = "ReadWrite" 
}
variable create_option{
    type = string
    default = "FromImage"  
}
variable managed_disk_type{
    type = string
    default = "Standard_LRS" 
}
variable publisher{
    type = string
    default = "MicrosoftWindowsServer"    
}
variable offer{
    type = string
    default = "WindowsServer"  
}
variable sku{
    type = string
    default = "2016-Datacenter"  
}

variable adminpassword{
    type = string
    
}