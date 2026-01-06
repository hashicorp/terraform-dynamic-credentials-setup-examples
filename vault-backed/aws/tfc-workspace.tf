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
# to Vault with the permissions set in the Vault policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to AWS.
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

resource "tfe_variable" "tfc_vault_namespace" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_NAMESPACE"
  value    = var.vault_namespace
  category = "env"

  description = "Namespace that contains the AWS Secrets Engine."
}

resource "tfe_variable" "enable_aws_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AWS_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Vault Secrets Engine integration for AWS."
}

resource "tfe_variable" "tfc_aws_mount_path" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AWS_MOUNT_PATH"
  value    = "aws"
  category = "env"

  description = "Path to where the AWS Secrets Engine is mounted in Vault."
}

resource "tfe_variable" "tfc_aws_auth_type" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AWS_AUTH_TYPE"
  value    = vault_aws_secret_backend_role.aws_secret_backend_role.credential_type
  category = "env"

  description = "Auth type used in the AWS Secrets Engine."
}

resource "tfe_variable" "tfc_aws_run_role_arn" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AWS_RUN_ROLE_ARN"
  value    = aws_iam_role.tfc_role.arn
  category = "env"

  description = "ARN of the AWS IAM Role the run will assume."
}

resource "tfe_variable" "tfc_aws_run_vault_role" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_VAULT_BACKED_AWS_RUN_VAULT_ROLE"
  value    = vault_aws_secret_backend_role.aws_secret_backend_role.name
  category = "env"

  description = "Name of the Role in Vault to assume via the AWS Secrets Engine."
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
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-backed/aws-configuration#specifying-multiple-configurations
# for specific requirements and details for Vault-backed AWS.

# resource "tfe_variable" "enable_aws_provider_auth_other_config" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_VAULT_BACKED_AWS_AUTH_other_config"
#   value    = "true"
#   category = "env"

#   description = "Enable the Vault Secrets Engine integration for AWS for an additional configuration named other_config."
# }
