# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "tfe" {
  hostname = var.tfc_hostname
}

# Data source used to grab the project under which a workspace will be created.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/project
data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = var.tfc_organization_name
}

# Runs in this workspace will be automatically authenticated
# to GCP with the permissions set in the GCP policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

# The provider name contains the project number, pool ID,
# and provider ID. This information can be supplied using
# this TFC_GCP_WORKLOAD_PROVIDER_NAME variable, or using
# the separate TFC_GCP_PROJECT_NUMBER, TFC_GCP_WORKLOAD_POOL_ID,
# and TFC_GCP_WORKLOAD_PROVIDER_ID variables below if desired.
#
resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}

# Uncomment the following variables and comment out
# tfc_gcp_workload_provider_name if you wish to supply this
# information in separate variables instead!

# resource "tfe_variable" "tfc_gcp_project_number" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_PROJECT_NUMBER"
#   value    = data.google_project.project.number
#   category = "env"

#   description = "The numeric identifier of the GCP project"
# }

# resource "tfe_variable" "tfc_gcp_workload_pool_id" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_POOL_ID"
#   value    = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
#   category = "env"

#   description = "The ID of the workload identity pool."
# }

# resource "tfe_variable" "tfc_gcp_workload_provider_id" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
#   value    = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
#   category = "env"

#   description = "The ID of the workload identity pool provider."
# }

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_service_account.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_gcp_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_gcp_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }

# The following is an example of the naming format used to define variables for
# additional configurations. Additional required configuration values must also
# be supplied in this same format, as well as any desired optional configuration
# values.
#
# Additional configurations can be used to uniquely authenticate multiple aliases
# of the same provider in a workspace, with different roles/permissions in different
# accounts or regions.
#
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/specifying-multiple-configurations
# for more details on specifying multiple configurations.
#
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/gcp-configuration#specifying-multiple-configurations
# for specific requirements and details for the GCP provider.

# resource "tfe_variable" "enable_gcp_provider_auth_other_config" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_PROVIDER_AUTH_other_config"
#   value    = "true"
#   category = "env"

#   description = "Enable the Workload Identity integration for GCP for an additional configuration named other_config."
# }
