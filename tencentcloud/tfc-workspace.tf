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
  organization = var.tfc_organization_name
}

# Runs in this workspace will be automatically authenticated
# to Tencent Cloud with the permissions set in the CAM policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to Tencent Cloud.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_tencentcloud_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_TENCENTCLOUD_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Tencent Cloud."
}

resource "tfe_variable" "tfc_tencentcloud_role_arn" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_TENCENTCLOUD_RUN_ROLE_ARN"
  value    = tencentcloud_cam_role.tfc_role.role_arn
  category = "env"

  description = "The Tencent Cloud CAM role ARN runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_tencentcloud_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_TENCENTCLOUD_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_tencentcloud_audience
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
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/tencentcloud-configuration#specifying-multiple-configurations
# for specific requirements and details for the Tencent Cloud provider.

# resource "tfe_variable" "enable_tencentcloud_provider_auth_other_config" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_TENCENTCLOUD_PROVIDER_AUTH_other_config"
#   value    = "true"
#   category = "env"

#   description = "Enable the Workload Identity integration for Tencent Cloud for an additional configuration named other_config."
# }
