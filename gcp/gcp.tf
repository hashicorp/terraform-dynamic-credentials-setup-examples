provider "google" {
  project = var.gcp_project_id
  region  = "global"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = "global"
}

# Adds support for subjects with project information, and for subjects without project information.
# All subject values in the future will include project information so this is a future proofing step
# for users who are not yet using projects, and required for users who are.
locals {
  non_project_sub_check = "organization:${var.tfc_organization_name}:workspace:${var.tfc_workspace_name}"
  project_sub_check = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}"
}

# Data source used to get the project number programmatically.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project
data "google_project" "project" {
}

# Enables the required services in the project.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "services" {
  count   = length(var.gcp_service_list)
  service = var.gcp_service_list[count.index]
}

# Creates a workload identity pool to house a workload identity
# pool provider.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool
resource "google_iam_workload_identity_pool" "tfc_pool" {
  provider                  = google-beta
  workload_identity_pool_id = "my-tfc-pool"
}

# Creates an identity pool provider which uses an attribute condition
# to ensure that only the specified Terraform Cloud workspace will be
# able to authenticate to GCP using this provider.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "my-tfc-provider-id"
  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
  oidc {
    issuer_uri        = "https://${var.tfc_hostname}"
    allowed_audiences = [var.tfc_gcp_audience]
  }
  attribute_condition = "assertion.sub.startsWith(\"${local.non_project_sub_check}\") || assertion.sub.startsWith(\"${local.project_sub_check}\")"
}

# Creates a service account that will be used for authenticating to GCP.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "tfc_service_account" {
  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
}

# Allows the service account to act as a workload identity user.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "tfc_service_account_member" {
  service_account_id = google_service_account.tfc_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc_pool.name}/*"
}

# Updates the IAM policy to grant the service account permissions
# within the project.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "tfc_project_member" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tfc_service_account.email}"
}
