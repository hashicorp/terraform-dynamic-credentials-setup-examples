# Bootstrapping trust between a TFC workspace and Vault

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to Vault using Workload Identity.

The basic building blocks in `vault.tf` will enable the `jwt` auth backend in Vault and create a role that is bound to a particular Terraform Cloud workspace.

The building blocks in `tfc-workspace.tf` will create that Terraform Cloud workspace and set all the configuration variables needed in order to allow runs to authenticate to Vault.

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `VAULT_TOKEN`: the Vault token that you'll use to bootstrap your trust configuration in Vault. It will need the ability to enable auth backends and create roles and policies.
1. `VAULT_NAMESPACE` (optional): only set this if you're not using the default Vault namespace.
1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization.

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to the given Vault instance, allowing you to use
the Vault Terraform provider to manage and retrieve secrets via Terraform.