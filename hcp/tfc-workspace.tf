# Copyright IBM Corp. 2022, 2025
# SPDX-License-Identifier: MPL-2.0

provider "tfe" {
  hostname = var.tfc_hostname
}

# Data source used to grab the project under which a workspace will be created.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/project
data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = var.organization_name
}

# Runs in this workspace will be automatically authenticated
# to HCP with the permissions set in the HCP policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to HCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_hcp_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_HCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for HCP."
}

# The resource name of the provider for which the external identity
# will be exchanged against using the credential file.
resource "tfe_variable" "tfc_hcp_provider_resource_name" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_HCP_RUN_PROVIDER_RESOURCE_NAME"
  value    = hcp_iam_workload_identity_provider.tfc.resource_name
  category = "env"

  description = "The resource name of the provider for which the external identity will be exchanged against using the credential file."
}

# The value to use as the `aud` claim in run identity tokens
resource "tfe_variable" "tfc_hcp_audience" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_HCP_WORKLOAD_IDENTITY_AUDIENCE"
  value    = var.tfc_hcp_audience
  category = "env"

  description = "The value to use as the audience claim in run identity tokens"
}
