# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Data source used to get the project id programmatically.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project
data "google_project" "current" {
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "secrets_engine" {
  account_id   = "hcp-vault-secrets-engine"
  display_name = "HCP Vault Secrets Engine"
}

# Updates the IAM policy to grant the service account permissions
# within the project.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "secrets_engine" {
  project = data.google_project.current.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.secrets_engine.email}"
}

# Credentials for HCP Vault to use to authenticate with GCP.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
resource "google_service_account_key" "secrets_engine_key" {
  service_account_id = google_service_account.secrets_engine.name
}