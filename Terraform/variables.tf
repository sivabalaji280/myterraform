variable "rg" {
  type        = string
  description = "resource group"
}

variable "location" {
  type        = string
  description = "location"
}
variable "my_nsg" {
  type        = string
  description = "NSG"
}

variable "my_vnet" {
  type = map(object({
    name          = string
    address_space = string
    subnet = map(object({
      name           = string
      address_prefix = string
    }))
  }))
}


# variables.tf

# variable "my_vnet" {
#   type = object({
#     name          = string
#     address_space = list(string)
#     subnet = object({
#       name           = string
#       address_prefix = string
#       address_space  = list(string)
#     })
#   })
# }


variable "my_vm" {
  type = map(object({
    name                 = string
    sku                  = string
    username             = string
    password             = string
    storage_account_type = string
    offer                = string
    os_sku               = string
    publisher            = string
    my_nic               = string
    pubip                = string
  }))
  description = "vms"
}


# variable "my_nic" {
#   type        = list(any)
#   description = "NIC cards"
# }

# variable "admin_password" {
#   type      = string
#   default   = "Admin!1234"
#   sensitive = true
# }

variable "clientid" {
  type        = string
  description = "clientid"
}

variable "tenantid" {
  type        = string
  description = "tenantid"
}

variable "secret" {
  type        = string
  description = "secret"
}

variable "subscription_id" {
  type        = string
  description = "subscription"
}
