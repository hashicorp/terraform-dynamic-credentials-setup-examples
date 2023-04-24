# Bootstrapping trust between a TFC workspace and Azure using Vault-Backed Azure Secrets Engine

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to Azure using Workload Identity and Vault's Azure Secrets Engine.

It contains the necessary configuration for adding both the Azure Secrets Engine and JWT/OIDC authentication to your Vault instance. It assumes you already have an existing Azure service principle and resource group. If you don't, you can create everything you need by following [this section](https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets#create-an-azure-service-principal-and-resource-group) of the tutorial for setting up an Azure Secrets Engine in Vault.

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `VAULT_TOKEN`: the Vault token that you'll use to bootstrap your trust configuration in Vault. It will need the ability to enable auth backends and create roles and policies.
1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization.

You'll also need to authenticate the Azure provider as you would normally using one of the methods mentioned in the Azure provider documentation [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default. You can acquire the majority of these variables by following [this section](https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets#create-an-azure-service-principal-and-resource-group) of the tutorial for setting up an Azure Secrets Engine in Vault.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to Azure when using the AzureRM or AzureAD Terraform providers.