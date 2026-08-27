# Bootstrapping trust between a TFC workspace and Tencent Cloud

This directory contains example code for setting up a Terraform Cloud workspace whose runs will be automatically authenticated to Tencent Cloud using Workload Identity.

The basic building blocks in `tencentcloud.tf` will create a CAM role that is bound to a particular Terraform Cloud workspace, trusting an OIDC identity provider you create as a prerequisite.

The building blocks in `tfc-workspace.tf` will create that Terraform Cloud workspace and set all the configuration variables needed in order to allow runs to authenticate to Tencent Cloud.

## Prerequisites

Before running Terraform, you must manually create a **Role-type OIDC Identity Provider** in Tencent Cloud CAM. This is a one-time setup step that cannot currently be performed via the Tencent Cloud Terraform provider.

### Using the Tencent Cloud Console

1. Navigate to **CAM → Identity Providers → Create Identity Provider**
2. Select **OIDC** as the type
3. Configure the provider:
   - **Name**: `app.terraform.io` (or your TFE hostname; this value must match `var.tencentcloud_oidc_provider_name`)
   - **Identity Provider URL**: `https://app.terraform.io` (or your TFE hostname)
   - **Client ID**: `tencentcloud.workload.identity` (or your custom audience value; must match `var.tfc_tencentcloud_audience`)
4. Complete the creation wizard

### Using the tccli

```sh
tccli cam CreateOIDCConfig \
  --Name "app.terraform.io" \
  --IdentityUrl "https://app.terraform.io" \
  --ClientId '["tencentcloud.workload.identity"]' \
  --Description "HCP Terraform workload identity provider"
```

## How to use

You'll need the Terraform CLI installed, and you'll need to set the following environment variables in your local shell:

1. `TFE_TOKEN`: a Terraform Cloud user token with permission to create workspaces within your organization.
2. `TENCENTCLOUD_SECRET_ID`: your Tencent Cloud secret ID.
3. `TENCENTCLOUD_SECRET_KEY`: your Tencent Cloud secret key.

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the required variables. You can also set values for any other variables you'd like to customize beyond the default.

Run `terraform plan` to verify your setup, and then run `terraform apply`.

Congratulations! You now have a Terraform Cloud workspace where runs will automatically authenticate to Tencent Cloud when using the Tencent Cloud Terraform provider.
