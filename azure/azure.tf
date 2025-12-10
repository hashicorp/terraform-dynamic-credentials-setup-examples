# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Data source used to get information about the current Azure AD tenant.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config
data "azuread_client_config" "current" {}

# Data source used to get the current subscription's ID.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription
data "azurerm_subscription" "current" {
}

# Fetches the Entra ID Application Administrator role object ID.
data "azuread_directory_role_templates" "all_roles" {}

locals {
  app_admin_role_id = one([
    for role in data.azuread_directory_role_templates.all_roles.role_templates : role.object_id
    if role.display_name == "Application Administrator"
  ])
}

# Creates an application registration within Azure Active Directory.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "tfc_application" {
  display_name = "tfc-application"
  owners       = [data.azuread_client_config.current.object_id]
}

# Creates a service principal associated with the previously created
# application registration.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "tfc_service_principal" {
  client_id = azuread_application.tfc_application.client_id
}

# Creates a role assignment which controls the permissions the service
# principal has within the Azure subscription.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "tfc_contributor_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Contributor"
}

# Creates a role assignment to allow the service principal to assign roles to resources it creates.
# This is required when Terraform provisions resources that need their own role assignments,
# such as managed identities, storage accounts, or service principals.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "tfc_rbac_role_assignment" {
  scope                            = data.azurerm_subscription.current.id
  principal_id                     = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name             = "Role Based Access Control Administrator"
  skip_service_principal_aad_check = true
}

# Assigns the service principal an Entra ID directory role to allow it to manage application registrations
# and service principals. 
# This is required when Terraform needs to create or manage Entra ID applications and service principals.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment
resource "azuread_directory_role_assignment" "tfc_app_admin_role_assignment" {
  # The role is assigned at the tenant/directory level, so the scope is the root directory - '/'
  # This argument defaults to '/' if omitted, but it is good practice to include it for clarity.
  directory_scope_id  = "/"
  principal_object_id = azuread_service_principal.tfc_service_principal.object_id
  role_id             = local.app_admin_role_id
}

# Creates a federated identity credential which ensures that the given
# workspace will be able to authenticate to Azure for the "plan" run phase.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential
resource "azuread_application_federated_identity_credential" "tfc_federated_credential_plan" {
  application_id = azuread_application.tfc_application.id
  display_name   = "my-tfc-federated-credential-plan"
  audiences      = [var.tfc_azure_audience]
  issuer         = "https://${var.tfc_hostname}"
  subject        = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
}

# Creates a federated identity credential which ensures that the given
# workspace will be able to authenticate to Azure for the "apply" run phase.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential
resource "azuread_application_federated_identity_credential" "tfc_federated_credential_apply" {
  application_id = azuread_application.tfc_application.id
  display_name   = "my-tfc-federated-credential-apply"
  audiences      = [var.tfc_azure_audience]
  issuer         = "https://${var.tfc_hostname}"
  subject        = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
}

