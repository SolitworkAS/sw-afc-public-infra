terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
    azapi = {
      source = "azure/azapi"
      version = "~> 1.10.0"
    }
  }

  required_version = ">= 1.1.0"
}