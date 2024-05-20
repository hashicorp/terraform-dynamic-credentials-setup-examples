# Bootstrapping trust between a TFC workspace and HCP

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to HCP using Workload Identity.

The basic building blocks in `hcp.tf` will configure a workload identity pool and provider and create a service principle that is bound to a particular Terraform Cloud workspace.

The building blocks in `tfc-workspace.tf` will create that Terraform Cloud workspace and set all the configuration variables needed in order to allow runs to authenticate to HCP.

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization
2. `HCP_CLIENT_ID`: ID of the service principal to configure HCP with, requires `roles/admin` on the organization
3. `HCP_CLIENT_SECRET`: Corresponding secret to the provided HCP client ID
4. `HCP_PROJECT_ID`: ID of the HCP project to create the new service principal that Terraform Cloud will be able to assume during runs

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to HCP when using the HCP provider.