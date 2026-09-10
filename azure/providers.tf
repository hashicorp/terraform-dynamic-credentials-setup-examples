terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.9.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.80.0"
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
