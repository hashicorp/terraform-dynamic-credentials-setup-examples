# Copyright IBM Corp. 2022, 2025
# SPDX-License-Identifier: MPL-2.0

variable "tfc_tencentcloud_audience" {
  type        = string
  default     = "tencentcloud.workload.identity"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Tencent Cloud"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "my-tencentcloud-workspace"
  description = "The name of the workspace that you'd like to create and connect to Tencent Cloud"
}

variable "tencentcloud_oidc_provider_name" {
  type        = string
  default     = "app.terraform.io"
  description = "The name of the Role OIDC Identity Provider created in Tencent Cloud CAM. Must match the name used when creating the provider as a prerequisite."
}
