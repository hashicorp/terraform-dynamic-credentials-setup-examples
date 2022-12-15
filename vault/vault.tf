provider "vault" {
  address = var.vault_url
}

# Adds support for subjects with project information, and for subjects without project information.
# All subject values in the future will include project information so this is a future proofing step
# for users who are not yet using projects, and required for users who are.
locals {
  non_project_sub = "organization:${var.tfc_organization_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
  project_sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
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
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = "tfc-role"
  token_policies = [vault_policy.tfc_policy.name]

  bound_audiences   = [var.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "${local.non_project_sub},${local.project_sub}"
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

# Configure the actual secrets the token should have access to
path "secret/*" {
  capabilities = ["read"]
}
EOT
}
