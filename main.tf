terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.53.0"
    }
  }
}

provider "azurerm" {

    features {}
  subscription_id = "a2ad4c5e-917a-40c0-a1b9-da92bd99e74f"
  client_id       = "0d32c66c-e0be-4a5f-b0d7-8cb39869219a"
  client_secret   = "3n67Q~bPdUsuGKAZzHBF2v3I6GIDE0l1MZHk~"
  tenant_id       = "415a8c7e-8647-4b46-b291-9cd6c3cde41d"
}

resource "azurerm_resource_group" "main" {
  name     = "vwantest"
  location = "eastus"
}


resource "azurerm_virtual_network" "vnet1" {
  name                = "virtualNetwork1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["192.168.1.0/24"]

}

resource "azurerm_virtual_network" "vnet2" {
  name                = "virtualNetwork2"
  location            = "Westus"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["192.168.2.0/24"]

}


module "vwan" {
  source = "./modules/vwan"
  name = "example-vwan"
  resource_group_name = azurerm_resource_group.main.name
  resource_group_location = azurerm_resource_group.main.location

   hubs = [
    {
      region = "eastus"
      prefix = "10.1.0.0/16"
    },
    {
      region = "westus"
      prefix = "10.2.0.0/16"
    },
  ]

     connections = [
    {
      region = "eastus"
      id = azurerm_virtual_network.vnet1.id
    },
    {
      region = "westus"
      id = azurerm_virtual_network.vnet2.id
    },
  ]

    depends_on = [
    azurerm_virtual_network.vnet1,azurerm_virtual_network.vnet2
  ]

}
