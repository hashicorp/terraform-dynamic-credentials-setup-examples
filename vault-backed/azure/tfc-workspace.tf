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
# to Vault with the permissions set in the Vault policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to Azure.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_vault_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "tfc_vault_addr" {
  workspace_id = tfe_workspace.my_workspace.id

  key       = "TFC_VAULT_ADDR"
  value     = var.vault_url
  category  = "env"
  sensitive = true

  description = "The address of the Vault instance runs will access."
}

resource "tfe_variable" "tfc_vault_role" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_RUN_ROLE"
  value    = vault_jwt_auth_backend_role.tfc_role.role_name
  category = "env"

  description = "The Vault role runs will use to authenticate."
}

resource "tfe_variable" "enable_azure_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AZURE_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Vault Secrets Engine integration for Azure."
}

resource "tfe_variable" "tfc_azure_mount_path" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AZURE_MOUNT_PATH"
  value    = vault_azure_secret_backend.azure_secret_backend.path
  category = "env"

  description = "Path to where the Azure Secrets Engine is mounted in Vault."
}

resource "tfe_variable" "tfc_azure_vault_role" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE"
  value    = vault_azure_secret_backend_role.azure_secret_backend_role.role
  category = "env"

  description = "Role to assume via the Azure Secrets Engine in Vault."
}

resource "tfe_variable" "tfc_azure_vault_namespace" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_NAMESPACE"
  value    = var.vault_namespace
  category = "env"

  description = "Namespace that contains the Azure Secrets Engine."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_vault_auth_path" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_VAULT_AUTH_PATH"
#   value    = var.jwt_backend_path
#   category = "env"

#   description = "The path where the jwt auth backend is mounted, if not using the default"
# }

# resource "tfe_variable" "tfc_vault_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_VAULT_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_vault_audience
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
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-backed/azure-configuration#specifying-multiple-configurations
# for specific requirements and details for Vault-backed Azure.

# resource "tfe_variable" "enable_azure_provider_auth_other_config" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_VAULT_BACKED_AZURE_AUTH_other_config"
#   value    = "true"
#   category = "env"

#   description = "Enable the Vault Secrets Engine integration for Azure for an additional configuration named other_config."
# }
