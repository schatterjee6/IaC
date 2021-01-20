variable "location" {
  description = "The location/region where the core network will be created"
  default     = "centralindia"
}


variable jmp-vmprefix{
    type = string
}

variable web-vmprefix{
    type = string
}

variable rg{
    type = string
}

variable rg1{
    type = string
}
variable vm_size{
    type = string
 }
variable caching{
    type = string
}
variable create_option{
    type = string
 }
variable managed_disk_type{
    type = string
}
variable publisher{
    type = string
 }
variable offer{
    type = string
}
variable sku{
    type = string
}

/*
variable admin_password{
    type = string 
}*/

 variable sharedvnet{
   type = string 
 }

 variable sharedspace{
   type = list
 }

 variable appvnet{
   type = string
 }

 variable sharedspaceapp{
   type = list
 }


  variable rg_arm{
   type = list
 }

 
