variable "project_id" {
  description = "The ID of the project to create the bucket in."
  type        = string
}

variable "region" {
  description = "The location of the bucket."
  type        = string
}

variable "shared_vpc_project" {
  description = "The project ID of the shared VPC"
  type        = string
  default = ""
}
variable "shared_vpc_project_vpc" {
  description = "The VPC in the shared VPC project"
  type        = string
}

variable "enabled_internal_dashboards" {
  description = "Enable the Dashboards to be internal (i.e. inside the gke)"
  type        = bool
  default = false
}

/******************************************
	1. GKE Kubernetes
 *****************************************/

variable "workload_identity_email" {
  type        = string
  description = "The service account used for the pods workload identity"
  default     = "tw-gke-workload-identity"
}

variable "gke_cluster_and_nodepools" {
  description = ""
  type = object({
    regional                           = bool
    disable_default_snat               = bool
    cluster_name                       = string
    network                            = string
    service_account                    = string
    subnetwork                         = string
    ip_range_pods                      = string
    ip_range_services                  = string
    master_ipv4_cidr_block             = string
    http_load_balancing                = bool
    network_policy                     = bool
    filestore_csi_driver               = bool
    backup_agent_config                = bool
    enable_private_endpoint            = bool
    enable_private_nodes               = bool
    enable_vertical_pod_autoscaling    = bool
    remove_default_node_pool           = bool
    create_service_account             = bool
    non_masquerade_cidrs               = list(string)
    upstream_nameservers               = list(string)
    ip_masq_resync_interval            = string
    ip_masq_link_local                 = bool
    configure_ip_masq                  = bool
    logging_service                    = string
    monitoring_service                 = string
    resource_usage_export_dataset_id   = string
    enable_network_egress_export       = bool
    enable_resource_consumption_export = bool
    enable_binary_authorization        = bool
    secrets_encryption_kms_key         = string
    node_metadata                      = string
    maintenance_start_time             = string
    default_max_pods_per_node          = number
    cluster_dns_provider               = string
    cluster_dns_scope                  = string
    release_channel                    = string
    enable_shielded_nodes              = bool
    tags                               = list(string)
    state                              = string
    master_authorized_networks         = list(object({ cidr_block = string, display_name = string }))
    node_pools_oauth_scopes            = map(any)
    cluster_resource_labels            = map(any)
    ingress_type                       = string
    node_pools = list(object({
      name                        = string
      machine_type                = string
      min_count                   = number
      max_count                   = number
      local_ssd_count             = number
      spot                        = bool
      preemptible                 = bool
      disk_size_gb                = number
      disk_type                   = string
      image_type                  = string
      node_count                  = number
      auto_repair                 = bool
      auto_upgrade                = bool
      service_account             = string
      initial_node_count          = number
      enable_secure_boot          = bool
      enable_integrity_monitoring = bool
      labels                      = map(any)
      taints                      = list(map(any))
    }))
  })
}

/******************************************
	2. ArgoCD Kubernetes
 *****************************************/

variable "org_id" {
  type        = string
  description = "Org ID"
  default     = null
}
variable "git_username" {
  type        = string
  description = "Git username for the ArgoCD"
  default     = ""
}
variable "git_token" {
  type        = string
  description = "Git Password for the ArgoCD"
  default     = ""
}

