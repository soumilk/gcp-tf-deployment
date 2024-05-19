variable "project_id" {
  description = "The ID of the project to create the bucket in."
  type        = string
}

variable "region" {
  description = "The location of the bucket."
  type        = string
}
/******************************************
	1. GCP Service Account
 *****************************************/

variable "gcp_service_accounts_list" {
  description = "Variable for creating service account and reqired permission"
  type = list(object({
    display_name  = string
    name          = string
    description   = string
    project_roles = list(string)
  }))
  default = []
}
