
terraform {
  required_providers {
    azurerm = {
       source  = "hashicorp/azurerm"
       version = "3.98.0"
     }
  }
  backend "azurerm" {
    resource_group_name  = "tf-backend"  
     storage_account_name = "tfbackendsgacc"
     container_name       = "tfstate"       
     key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {

  }
  client_id       = var.clientid
  client_secret   = var.secret
  tenant_id       = var.tenantid
  subscription_id = var.subscription_id
}