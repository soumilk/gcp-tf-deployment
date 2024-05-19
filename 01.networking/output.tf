output "project_number" {
  value = data.google_project.project.number
}

output "network_name" {
  value       = module.tw_networking.network_name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = module.tw_networking.network_id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = module.tw_networking.network_self_link
  description = "The URI of the VPC being created"
}
