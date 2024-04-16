locals {
  my_networks = flatten([
    for vnet_key, vnet_value in var.my_vnet : [
      for subnet_key, subnet_value in vnet_value.subnet : {
        name           = vnet_value.name
        address_space  = vnet_value.address_space
        subnet_name    = subnet_value.name
        address_prefix = subnet_value.address_prefix
      }
    ]
  ])
}


resource "azurerm_network_security_group" "nsg" {
  name                = var.my_nsg
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}



resource "azurerm_virtual_network" "vnet" {

  for_each = tomap({
    for subnet in local.my_networks : subnet.subnet_name => subnet
  })

  name                = each.value.name
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  address_space       = ["${each.value.address_space}"]


  subnet {
    name           = each.value.subnet_name
    address_prefix = each.value.address_prefix
  }

}