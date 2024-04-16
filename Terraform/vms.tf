

locals {
  my_vms = flatten([
    for vmname, vmdata in var.my_vm : {
      name                 = vmdata.name
      sku                  = vmdata.sku
      username             = vmdata.username
      password             = vmdata.password
      storage_account_type = vmdata.storage_account_type
      offer                = vmdata.offer
      os_sku               = vmdata.os_sku
      publisher            = vmdata.publisher
      my_nic = vmdata.my_nic
      pubip = vmdata.pubip
    }
  ])
}

locals {
  my_networks_vm = flatten([
    for vnet_key, vnet_value in var.my_vnet : [
      for subnet_key, subnet_value in vnet_value.subnet : {
        name           = vnet_key
        address_space  = vnet_value.address_space
        subnet_name    = subnet_key
        address_prefix = subnet_value.address_prefix
      }
    ]
  ])
}

data "azurerm_subnet" "subnet" {
  for_each = tomap({
    for subnet in local.my_networks : subnet.subnet_name => subnet
  })


  name                 = each.value.subnet_name
  virtual_network_name = each.value.name
  resource_group_name  = azurerm_resource_group.myrg.name
  depends_on = [ azurerm_virtual_network.vnet ]
}





data "azurerm_network_interface" "my_nic" {
  for_each = tomap({
    for my_nic in local.my_vms : my_nic.name => my_nic
  })

  name                = each.value.my_nic
  resource_group_name = azurerm_resource_group.myrg.name
  depends_on = [ azurerm_network_interface.nic]
}


resource "azurerm_public_ip" "my_pubip" {
  for_each = tomap({
    for vmname, vmdata in local.my_vms : vmname => vmdata
  })

  name                = each.value.pubip
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  for_each = tomap({
    for vmname, vmdata in local.my_vms : vmname => vmdata
  })

  

  name                = each.value.my_nic
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet["tf-subnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_pubip[each.key].id
  }
}
# local.my_networks_vm[each.key].name

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = tomap({
    for vmname, vmdata in local.my_vms : vmname => vmdata
  })

  name                            = each.value.name
  resource_group_name             = azurerm_resource_group.myrg.name
  location                        = azurerm_resource_group.myrg.location
  size                            = each.value.sku
  admin_username                  = each.value.username
  admin_password                  = each.value.password
  disable_password_authentication = false
  network_interface_ids           = [data.azurerm_network_interface.my_nic[each.value.name].id]
  depends_on                      = [azurerm_network_interface.nic]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.os_sku
    version   = "latest"
  }



# provisioner "local-exec" {
#   command = <<-EOT
#     mkdir -p ~/shiva &&
#     chmod -R 755 ~/shiva &&
#     echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLGZLkt/kf8Sp/NjQsAdVX4HR3I9PuCCuZtmQ9vtWp6IkrFRTxvQungCNjQu+pC1LLrirhi4RfUYIHp6VG4zStkoNv+sVFRPPc2d+KbZrCCEzMDnUnLbatu1l4/CcO7QD6tEfQph83kDhLGhMuyojxe0Bd1qV9ggGEwzpQ/insx8InQTRDiCpdg4vrLZkzMICq9YH3NWxUk/HdOy/+EMH0kh9e4NEezr712xlKluoEug3ryv25b6HBqiG1bfwTB7nxVjfy/chd9xSGFYo1WAjpDLjiGeQY2F2oWjh7YkZhgwBMGlZhtiGk33k/7wx8verWzQU2nUQ1/NNkWUrPs6HhGRLGl5Xg600gZrsFNnum5xlhxHnBeOMExGc4ZigYWW9djwm9/AReVTIvtkgIRIgXDKZC4zt0P14vizwtpu0aKb05PM2qr2aFBfc2czVRUYbmC0/U9aFcaZVsgepWDnNpEpG6DmtLPMYhurM1PrAljPd1nohfGTt5FHTJ+Zt72XU= sivabalaji@tf-vm" >> ~/shiva/authorized_keys &&
#     chmod 644 ~/shiva/authorized_keys
#   EOT
# }
# provisioner "file" {
#     source = ./pubkey
#     destination = ~
#     }  
provisioner "remote-exec" {
    inline = [
      
      "sudo touch ~/.ssh/authorized_keys",
      "sudo sh -c 'echo \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLGZLkt/kf8Sp/NjQsAdVX4HR3I9PuCCuZtmQ9vtWp6IkrFRTxvQungCNjQu+pC1LLrirhi4RfUYIHp6VG4zStkoNv+sVFRPPc2d+KbZrCCEzMDnUnLbatu1l4/CcO7QD6tEfQph83kDhLGhMuyojxe0Bd1qV9ggGEwzpQ/insx8InQTRDiCpdg4vrLZkzMICq9YH3NWxUk/HdOy/+EMH0kh9e4NEezr712xlKluoEug3ryv25b6HBqiG1bfwTB7nxVjfy/chd9xSGFYo1WAjpDLjiGeQY2F2oWjh7YkZhgwBMGlZhtiGk33k/7wx8verWzQU2nUQ1/NNkWUrPs6HhGRLGl5Xg600gZrsFNnum5xlhxHnBeOMExGc4ZigYWW9djwm9/AReVTIvtkgIRIgXDKZC4zt0P14vizwtpu0aKb05PM2qr2aFBfc2czVRUYbmC0/U9aFcaZVsgepWDnNpEpG6DmtLPMYhurM1PrAljPd1nohfGTt5FHTJ+Zt72XU= sivabalaji@tf-vm\" >> ~/.ssh/authorized_keys'"
    ]

    connection {
      type     = "ssh"
      user     = each.value.username # Replace with your username
      password = each.value.password # Replace with your password or use SSH key authentication
      host     = self.public_ip_address
    }
}

# provisioner "file" {
#     source      = "./pubkey"
#     destination = "~/.ssh/authorized_keys"
#   }

# command = <<-EOT
#       mkdir -p ~/.ssh &&
#       echo "$(cat ./pubkey)" >> ~/.ssh/authorized_keys &&
#       chmod 600 ~/.ssh/authorized_keys
#     EOT

  # provisioner "local-exec" {
  #   command = "echo $(cat ./Terraform/pubkey) >> ~/.ssh/authorized_keys"
  # }

  # provisioner "local-exec" {
  #   command = "chmod 644 ~/.ssh/authorized_keys"
  # }


}

# locals {
#   script_base64 = base64encode("echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLGZLkt/kf8Sp/NjQsAdVX4HR3I9PuCCuZtmQ9vtWp6IkrFRTxvQungCNjQu+pC1LLrirhi4RfUYIHp6VG4zStkoNv+sVFRPPc2d+KbZrCCEzMDnUnLbatu1l4/CcO7QD6tEfQph83kDhLGhMuyojxe0Bd1qV9ggGEwzpQ/insx8InQTRDiCpdg4vrLZkzMICq9YH3NWxUk/HdOy/+EMH0kh9e4NEezr712xlKluoEug3ryv25b6HBqiG1bfwTB7nxVjfy/chd9xSGFYo1WAjpDLjiGeQY2F2oWjh7YkZhgwBMGlZhtiGk33k/7wx8verWzQU2nUQ1/NNkWUrPs6HhGRLGl5Xg600gZrsFNnum5xlhxHnBeOMExGc4ZigYWW9djwm9/AReVTIvtkgIRIgXDKZC4zt0P14vizwtpu0aKb05PM2qr2aFBfc2czVRUYbmC0/U9aFcaZVsgepWDnNpEpG6DmtLPMYhurM1PrAljPd1nohfGTt5FHTJ+Zt72XU= sivabalaji@tf-vm' >> ~/.ssh/authorized_keys")
# }

# resource "azurerm_virtual_machine_extension" "my_extention" {

#   for_each = tomap({
#     for vmname, vmdata in local.my_vms : vmname => vmdata
#   })

#   name                 = each.value.name
#   virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
# {
#   "script": "${local.script_base64}"
# }
# SETTINGS
# }
