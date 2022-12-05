provider "tfe" {
  hostname = var.tfc_hostname
}

# Runs in this workspace will be automatically authenticated
# to GCP with the permissions set in the GCP policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
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

resource "tfe_variable" "tfc_gcp_project_number" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_PROJECT_NUMBER"
  value    = data.google_project.project.number
  category = "env"

  description = "The numeric identifier of the GCP project"
}

resource "tfe_variable" "tfc_gcp_workload_pool_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_WORKLOAD_POOL_ID"
  value    = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  category = "env"

  description = "The ID of the workload identity pool."
}

resource "tfe_variable" "tfc_gcp_workload_provider_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
  category = "env"

  description = "The ID of the workload identity pool provider."
}

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
