# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "hcp" {}

# Project data resource that is used to fetch information about the current HCP project
#
# https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/data-sources/project
data "hcp_project" "hcp_project" {
}

# The service principal resource manages a HCP Service Principal.
#
# https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/service_principal
resource "hcp_service_principal" "workload_sp" {
  name = "hcp-terraform"
  parent = data.hcp_project.hcp_project.resource_name
}

# Grants the service principal the ability to provision and destroy resources in HCP
#
# https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/project_iam_binding
resource "hcp_project_iam_binding" "workload_sp_binding" {
  project_id   = data.hcp_project.hcp_project.resource_id
  principal_id = hcp_service_principal.workload_sp.resource_id
  role         = "roles/contributor"
}

locals {
  sub_regex = "^organization:${var.organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:.*"
}

# The workload identity provider resource allows federating an external identity to an HCP Service Principal.
#
# https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/iam_workload_identity_provider
resource "hcp_iam_workload_identity_provider" "tfc" {
  name              = "hcp-terraform-provider"
  service_principal = hcp_service_principal.workload_sp.resource_name
  description       = "Allow HCP Terraform agents to act as the ${hcp_service_principal.workload_sp.name} service principal"

  oidc = {
    issuer_uri = "https://${var.tfc_hostname}"
    allowed_audiences = [var.tfc_hcp_audience]
  }

  conditional_access = "jwt_claims.sub matches `${local.sub_regex}`"
}
