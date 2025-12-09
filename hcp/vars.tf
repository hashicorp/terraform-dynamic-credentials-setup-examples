# Copyright IBM Corp. 2022, 2025
# SPDX-License-Identifier: MPL-2.0

variable "tfc_hcp_audience" {
  type        = string
  default     = "hcp.workload.identity"
  description = "The audience value to use in run identity tokens if the default audience value is not desired."
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with HCP"
}

variable "organization_name" {
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
  default     = "my-hcp-workspace"
  description = "The name of the workspace that you'd like to create and connect to HCP"
}
