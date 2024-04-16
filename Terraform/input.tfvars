rg       = "tf-resourcegroup"
location = "East Us"
my_nsg   = "tf-nsg"

# my_vnet = {
#   name          = "tf-vnet01"
#   address_space = ["10.19.1.0/26"]
#   subnet = {
#     name           = "tf-subnet01"
#     address_prefix = "10.19.1.0/26"
#   }
# }

# input.tfvars

# input.tfvars

# input.tfvars

my_vnet = {
  tf-vnet01 = {
    name          = "tf-vnet01"
    address_space = "10.19.1.0/26"
    subnet = {
      tf-subnet01 = {
        name           = "tf-subnet01"
        address_prefix = "10.19.1.0/26"
      }
    }
  }
}




my_vm = {
  tf-vm01 = {
    name                 = "tf-vm01"
    sku                  = "Standard_B2s"
    username             = "sivabalaji"
    password = "Ansible@1234"
    storage_account_type = "Standard_LRS"
    offer                = "0001-com-ubuntu-server-jammy"
    os_sku               = "22_04-lts"
    publisher            = "Canonical"
    my_nic               = "tf-nic"
    pubip                = "tf-pubip"
  }
}





