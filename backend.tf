terraform {
  backend "azurerm" {
    storage_account_name = "netflixstrage12"
    container_name       = "blobcontainer"
    resource_group_name  = "VM_RG"
    key                  = "terraform.tfstate"
  }
}