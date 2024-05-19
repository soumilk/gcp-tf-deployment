output "cluster_id" {
  description = "Cluster ID"
  value       = module.tw_gke.cluster_id
}

output "self_link" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = module.tw_gke.self_link
}

output "endpoint" {
  description = "Cluster endpoint"
  value       = module.tw_gke.endpoint
}

output "cluster_ca_certificate" {
  value     = module.tw_gke.cluster_ca_certificate
  sensitive = true
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = module.tw_gke.master_version
}