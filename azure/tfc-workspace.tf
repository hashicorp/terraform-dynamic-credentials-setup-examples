provider "tfe" {
  hostname = var.tfc_hostname
}

# Runs in this workspace will be automatically authenticated
# to Azure with the permissions set in the Azure policy. TODO: che k if wording right
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
}

# The following variables must be set to allow runs
# to authenticate to Azyre.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_azure_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AZURE_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Azure."
}

resource "tfe_variable" "tfc_azure_client_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AZURE_RUN_CLIENT_ID"
  value    = azuread_application.tfc_application.application_id
  category = "env"

  description = "The Azure Client ID runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_azure_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_AZURE_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_azure_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }
