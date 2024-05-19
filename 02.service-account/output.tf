
output "id" {
  description = "an identifier for the resource with format projects/{{project}}/serviceAccounts/{{email}}"
  value       = { for k, v in module.tw_service_accounts : k => v.id }
}

output "email" {
  description = "The e-mail address of the service account."
  value       = { for k, v in module.tw_service_accounts : k => v.email }
}

output "name" {
  description = "The fully-qualified name of the service account."
  value       = { for k, v in module.tw_service_accounts : k => v.name }
}

output "member" {
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."
  value       = { for k, v in module.tw_service_accounts : k => v.member }
}
