# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "vault" {
  address = var.vault_url
}

# Enables the jwt auth backend in Vault at the given path,
# and tells it where to find TFC's OIDC metadata endpoints.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend
resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = var.jwt_backend_path
  type               = "jwt"
  oidc_discovery_url = "https://${var.tfc_hostname}"
  bound_issuer       = "https://${var.tfc_hostname}"
}

# Creates a role for the jwt auth backend and uses bound claims
# to ensure that only the specified Terraform Cloud workspace will
# be able to authenticate to Vault using this role.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role
resource "vault_jwt_auth_backend_role" "tfc_role" {
  namespace      = var.vault_namespace
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = "tfc-role"
  token_policies = [vault_policy.tfc_policy.name]

  bound_audiences   = [var.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

# Creates a policy that will control the Vault permissions
# available to your Terraform Cloud workspace. Note that
# tokens must be able to renew and revoke themselves.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "tfc_policy" {
  name = "tfc-policy"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow Access to GCP Secrets Engine
path "/gcp/roleset/${vault_gcp_secret_roleset.gcp_secret_roleset.roleset}/token" {
    capabilities = ["read"]
}
EOT
}


# Creates an GCP Secret Backend for Vault. GCP secret backends can then issue GCP OAuth token or 
# Service Account keys, once a role has been added to the backend.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/gcp_secret_backend
resource "vault_gcp_secret_backend" "gcp_secret_backend" {
  namespace = var.vault_namespace
  path      = "gcp"

  # WARNING - These values will be written in plaintext in the statefiles for this configuration. 
  # Protect the statefiles for this configuration accordingly!
  credentials = base64decode(google_service_account_key.secrets_engine_key.private_key)

  depends_on = [
    google_service_account.secrets_engine,
    google_project_iam_member.secrets_engine
  ]
}

# 
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/gcp_secret_roleset
resource "vault_gcp_secret_roleset" "gcp_secret_roleset" {
  backend      = vault_gcp_secret_backend.gcp_secret_backend.path
  roleset      = "project_viewer"
  secret_type  = "access_token"
  project      = var.gcp_project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"

    roles = [
      "roles/viewer",
    ]
  }

  depends_on = [
    google_service_account.secrets_engine,
    google_project_iam_member.secrets_engine
  ]
}