terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.69.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription_id
}

provider "azuread" {
}

provider "tfe" {
  hostname = var.tfc_hostname
  token    = var.tfc_token
}
