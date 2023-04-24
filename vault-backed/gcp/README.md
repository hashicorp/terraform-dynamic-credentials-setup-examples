# Bootstrapping trust between a TFC workspace and GCP using Vault-Backed GCP Secrets Engine

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to GCP using Workload Identity and Vault's GCP Secrets Engine.

It contains the necessary configuration for adding both the GCP Secrets Engine and JWT/OIDC authentication to your Vault instance, as well as a user and credentials for your Vault instance to use within your GCP account.

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `VAULT_TOKEN`: the Vault token that you'll use to bootstrap your trust configuration in Vault. It will need the ability to enable auth backends and create roles and policies.
1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization.

You'll also need to authenticate the GCP provider as you would normally using one of the methods mentioned in the GCP provider documentation [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials).

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to GCP when using the GCP Terraform provider.