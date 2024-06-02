

project_id = "<project_id>"
region     = "asia-south1"
shared_vpc_project = ""
shared_vpc_project_vpc = ""
workload_identity_email = "tw-gke-workload-identity"

gke_cluster_and_nodepools = {
  regional                           = true
  disable_default_snat               = false
  cluster_name                       = "tw-gke-cluster"
  network                            = "tw-vpc-network" # For Shared VPC, set this to the self link of the shared network.
  service_account                    = "tw-gke-cluster"
  subnetwork                         = "tw-vpc-subnet-gke-01"
  ip_range_pods                      = "tw-vpc-subnet-gke-pod-01"
  ip_range_services                  = "tw-vpc-subnet-gke-svc-01"
  master_ipv4_cidr_block             = "10.23.255.224/28"
  http_load_balancing                = true
  network_policy                     = false
  filestore_csi_driver               = false
  backup_agent_config                = false
  enable_private_endpoint            = false # When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used.
  enable_private_nodes               = true
  enable_vertical_pod_autoscaling    = false
  remove_default_node_pool           = true
  create_service_account             = false
  non_masquerade_cidrs               = []
  upstream_nameservers               = []
  ip_masq_resync_interval            = ""
  ip_masq_link_local                 = false
  configure_ip_masq                  = false
  logging_service                    = "logging.googleapis.com/kubernetes"
  monitoring_service                 = "monitoring.googleapis.com/kubernetes"
  resource_usage_export_dataset_id   = ""
  enable_network_egress_export       = false
  enable_resource_consumption_export = false
  enable_binary_authorization        = false
  secrets_encryption_kms_key         = ""
  node_metadata                      = "UNSPECIFIED"
  maintenance_start_time             = "2024-01-01T07:00:00Z"
  default_max_pods_per_node          = 35
  cluster_dns_provider               = "CLOUD_DNS"
  cluster_dns_scope                  = "CLUSTER_SCOPE"
  release_channel                    = "STABLE"
  enable_shielded_nodes              = true
  tags                               = ["tw"]
  state                              = "ENCRYPTED"
  master_authorized_networks         = []
  # master_authorized_networks = [
  #   {
  #     cidr_block   = "10.23.255.224/32",
  #     display_name = "master-enabled-nw-1"
  #   },
  #   {
  #     cidr_block   = "10.23.252.0/24",
  #     display_name = "bastion-host-ip-range"
  #   }
  # ]
  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
    all = []
  }
  cluster_resource_labels = {
    "environment" : "prod",
    "appname" : "tw",
    "created-with" : "terraform",
  }
  ingress_type = "public" # or private
  node_pools = [
    {
      name                        = "application"
      machine_type                = "n2-standard-4"
      min_count                   = 0
      max_count                   = 3
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-balanced" //pd-balanced
      image_type                  = "COS_CONTAINERD"
      node_count                  = 1
      enable_gcfs                 = false
      enable_gvnic                = false
      auto_repair                 = true
      auto_upgrade                = true
      service_account             = "tw-gke" //add the gke service account
      preemptible                 = false
      initial_node_count          = 1
      enable_secure_boot          = true
      enable_integrity_monitoring = true
      workload_metadata_config = {
        node_metadata = "GKE_METADATA_SERVER"
      }
      labels = {
        "hyenodepool" : "application"
      }
      taints = [
        {
          effect = "NO_SCHEDULE"
          key    = "application-pool"
          value  = "true"
        }
      ]
    }
  ]
}