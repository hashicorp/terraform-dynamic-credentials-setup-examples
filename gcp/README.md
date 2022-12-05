# Bootstrapping trust between a TFC workspace and GCP

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to GCP using Workload Identity.

The basic building blocks in `gcp.tf` will configure a workload identity pool and provider and create a service account that is bound to a particular Terraform Cloud workspace.

The building blocks in `tfc-workspace.tf` will create that Terraform Cloud workspace and set all the configuration variables needed in order to allow runs to authenticate to GCP.

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization.

You'll also need to authenticate the GCP provider as you would normally using one of the methods mentioned in the GCP provider documentation [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials).

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to GCP instance when using the GCP provider.