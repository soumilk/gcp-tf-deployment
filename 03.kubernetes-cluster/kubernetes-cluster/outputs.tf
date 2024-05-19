output "cluster_id" {
  description = "Cluster ID"
  value       = local.gke_cluster_primary.id
}

output "self_link" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = local.gke_cluster_primary.self_link
}

output "endpoint" {
  description = "Cluster endpoint"
  value       = local.gke_cluster_primary.endpoint
  depends_on = [
    /* Nominally, the endpoint is populated as soon as it is known to Terraform.
    * However, the cluster may not be in a usable state yet.  Therefore any
    * resources dependent on the cluster being up will fail to deploy.  With
    * this explicit dependency, dependent resources can wait for the cluster
    * to be up.
    */
    google_container_cluster.tw_gke_cluster,
    google_container_node_pool.tw_primary_nodepools,
  ]
}

output "cluster_ca_certificate" {
  value     = base64decode(local.gke_cluster_primary.master_auth[0].cluster_ca_certificate)
  sensitive = true
}

output "master_version" {
  description = "Current master kubernetes version"
  value       = local.gke_cluster_primary.master_version
}
