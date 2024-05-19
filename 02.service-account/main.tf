
module "tw_service_accounts" {
  source        = "./service-account"
  for_each      = { for account in var.gcp_service_accounts_list : account.display_name => account }
  project_id    = var.project_id
  account_id    = each.value.name
  display_name  = each.value.display_name
  project_roles = each.value.project_roles
}
