# Copyright IBM Corp. 2022, 2025
# SPDX-License-Identifier: MPL-2.0

provider "tencentcloud" {
}

# Data source used to look up the current account's owner UIN, which is
# required when constructing CAM QCS ARNs.
#
# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/data-sources/user_info
data "tencentcloud_user_info" "current" {
}

# Creates a role which can only be assumed by the specified Terraform
# Cloud workspace via OIDC workload identity.
#
# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cam_role
resource "tencentcloud_cam_role" "tfc_role" {
  name             = "tfc-role"
  console_login    = false
  session_duration = 7200

  document = jsonencode({
    version = "2.0"
    statement = [
      {
        action = "name/sts:AssumeRoleWithWebIdentity"
        effect = "allow"
        principal = {
          federated = [
            "qcs::cam::uin/${data.tencentcloud_user_info.current.owner_uin}:oidc-provider/${var.tencentcloud_oidc_provider_name}"
          ]
        }
        condition = {
          string_equal = {
            "oidc:iss" = "https://${var.tfc_hostname}"
            "oidc:aud" = var.tfc_tencentcloud_audience
          }
          string_like = {
            "oidc:sub" = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
          }
        }
      }
    ]
  })
}

# Creates a policy that will be used to define the permissions that
# the previously created role has within Tencent Cloud.
#
# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cam_policy
resource "tencentcloud_cam_policy" "tfc_policy" {
  name        = "tfc-policy"
  description = "TFC run policy"

  document = jsonencode({
    version = "2.0"
    statement = [
      {
        action   = ["name/cos:GetBucket"]
        effect   = "allow"
        resource = ["*"]
      }
    ]
  })
}

# Creates an attachment to associate the above policy with the
# previously created role.
#
# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cam_role_policy_attachment
resource "tencentcloud_cam_role_policy_attachment" "tfc_policy_attachment" {
  role_id   = tencentcloud_cam_role.tfc_role.id
  policy_id = tencentcloud_cam_policy.tfc_policy.id
}
