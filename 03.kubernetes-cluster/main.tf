data "google_compute_network" "tw-vpc" {
  name    = var.gke_cluster_and_nodepools.network
  project = var.project_id
}

#data "google_compute_subnetwork" "tw-vpc-subnet" {
#  for_each = { for x in var.gke_cluster_and_nodepools : x.cluster_name => x }
#  name     = each.value.subnetwork
#  region   = each.value.region
#  project  = each.value.project_host
#}

module "tw_gke" {
  source                          = "./kubernetes-cluster"
  project_id                      = var.project_id
  region                          = var.region
  enabled_internal_dashboards     = var.enabled_internal_dashboards
  workload_identity_email         = var.workload_identity_email
  regional                        = var.gke_cluster_and_nodepools.regional
  disable_default_snat            = var.gke_cluster_and_nodepools.disable_default_snat
  name                            = var.gke_cluster_and_nodepools.cluster_name
  network                         = var.gke_cluster_and_nodepools.network
  service_account                 = var.gke_cluster_and_nodepools.service_account
  subnetwork                      = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.gke_cluster_and_nodepools.subnetwork}"
  ip_range_pods                   = var.gke_cluster_and_nodepools.ip_range_pods
  ip_range_services               = var.gke_cluster_and_nodepools.ip_range_services
  master_ipv4_cidr_block          = var.gke_cluster_and_nodepools.master_ipv4_cidr_block
  http_load_balancing             = var.gke_cluster_and_nodepools.http_load_balancing
  network_policy                  = var.gke_cluster_and_nodepools.network_policy
  filestore_csi_driver            = var.gke_cluster_and_nodepools.filestore_csi_driver
  enable_private_endpoint         = var.gke_cluster_and_nodepools.enable_private_endpoint
  enable_private_nodes            = var.gke_cluster_and_nodepools.enable_private_nodes
  enable_vertical_pod_autoscaling = var.gke_cluster_and_nodepools.enable_vertical_pod_autoscaling
  remove_default_node_pool        = var.gke_cluster_and_nodepools.remove_default_node_pool
  create_service_account          = var.gke_cluster_and_nodepools.create_service_account
  logging_service                 = var.gke_cluster_and_nodepools.logging_service
  monitoring_service              = var.gke_cluster_and_nodepools.monitoring_service
  enable_binary_authorization     = var.gke_cluster_and_nodepools.enable_binary_authorization
  maintenance_start_time          = var.gke_cluster_and_nodepools.maintenance_start_time
  default_max_pods_per_node       = var.gke_cluster_and_nodepools.default_max_pods_per_node
  cluster_dns_provider            = var.gke_cluster_and_nodepools.cluster_dns_provider
  cluster_dns_scope               = var.gke_cluster_and_nodepools.cluster_dns_scope
  release_channel                 = var.gke_cluster_and_nodepools.release_channel
  enable_shielded_nodes           = var.gke_cluster_and_nodepools.enable_shielded_nodes
  master_authorized_networks      = var.gke_cluster_and_nodepools.master_authorized_networks
  tags                            = var.gke_cluster_and_nodepools.tags
  cluster_resource_labels         = var.gke_cluster_and_nodepools.cluster_resource_labels
  ingress_type                    = var.gke_cluster_and_nodepools.ingress_type
  node_pools                      = var.gke_cluster_and_nodepools.node_pools
}