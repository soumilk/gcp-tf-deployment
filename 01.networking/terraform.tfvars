
project_id                                 = "<project-id>"
region                                     = "asia-south1"
vpc_name                                   = "tw-vpc-network"
vpc_delete_default_internet_gateway_routes = false
vpc_description                            = "The VPC where the tw is hosted"

#shared_vpc_host_project = true
#shared_vpc_service_project = true
#shared_vpc_host_project_id = "<project_id>"

subnets = [
  {
    subnet_name           = "tw-vpc-subnet-gke-01"
    subnet_ip_range       = "10.23.240.0/22"
    subnet_region         = "asia-south1"
    subnet_private_access = true
    subnet_flow_logs      = true
    description           = "Subnet for GKE"
    secondary_ip_ranges = [
      {
        range_name    = "tw-vpc-subnet-gke-pod-01"
        ip_cidr_range = "10.23.224.0/20"
      },
      {
        range_name    = "tw-vpc-subnet-gke-svc-01"
        ip_cidr_range = "10.23.253.0/24"
      }
    ]
  }
]

### Default
# cloud_nat = {
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
#   log_config_enable                  = false
#   nat_log_config_filter              = "ALL"
# }

firewall_rules = []