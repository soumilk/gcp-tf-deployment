variable "project_id" {
  type        = string
  description = "Project id where service account will be created."
}

variable "prefix" {
  type        = string
  description = "Prefix applied to service account names."
  default     = ""
}

variable "account_id" {
  type        = string
  description = "Names of the service accounts to create."
  default     = null
}

variable "project_roles" {
  type        = list(string)
  description = "Common roles to apply to all service accounts, project=>role as elements."
  default     = []
}

variable "display_name" {
  type        = string
  description = "Display names of the created service accounts (defaults to 'Terraform-managed service account')"
  default     = "Terraform-managed service account"
}

variable "description" {
  type        = string
  description = "Default description of the created service accounts (defaults to no description)"
  default     = ""
}

variable "descriptions" {
  type        = list(string)
  description = "List of descriptions for the created service accounts (elements default to the value of `description`)"
  default     = []
}
