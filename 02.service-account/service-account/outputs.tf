
output "id" {
  description = "an identifier for the resource with format projects/{{project}}/serviceAccounts/{{email}}"
  value       = google_service_account.service_account.id
}

output "email" {
  description = "The e-mail address of the service account."
  value       = google_service_account.service_account.email
}

output "name" {
  description = "The fully-qualified name of the service account."
  value       = google_service_account.service_account.name
}

output "member" {
  description = "The Identity of the service account in the form serviceAccount:{email}. This value is often used to refer to the service account in order to grant IAM permissions."
  value       = google_service_account.service_account.member
}
