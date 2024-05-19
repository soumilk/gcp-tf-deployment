variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = null
}
variable "region" {
  type        = string
  description = "The region to create resource"
}


/******************************************
	1. VPC configuration
 *****************************************/
variable "vpc_name" {
  type        = string
  description = "The name of the VPC network being created"
  default     = "vpc-tw-prod-01"
}
variable "vpc_description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated to modify this field."
  default     = ""
}
variable "vpc_auto_create_subnetworks" {
  type        = bool
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. When set to false, the network is created in 'custom subnet mode' so the user can explicitly connect subnetwork resources."
  default     = false
}
variable "vpc_routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.vpc_routing_mode)
    error_message = "Valid values for vpc_routing_mode are (GLOBAL, REGIONAL)"
  }
}
variable "vpc_delete_default_internet_gateway_routes" {
  type        = bool
  description = "If set, ensure that all routes within the network specified whose names begin with 'default-route' and with a next hop of 'default-internet-gateway' are deleted"
  default     = false
}

/******************************************
	1.1 Shared VPC (Conditional)
 *****************************************/
variable "shared_vpc_host_project" {
  type        = bool
  description = "Makes this project a Shared VPC host if 'true' (default 'false')"
  default     = false
}
variable "shared_vpc_service_project" {
  type        = bool
  description = "Makes this project a Shared VPC Service project if 'true' (default 'false')"
  default     = false
}
variable "shared_vpc_host_project_id" {
  type        = string
  description = "ID of the project which is the host for this service project, only applicable if this is a shared vpc service project"
  default     = null
}


/******************************************
	2. Subnet configuration
 *****************************************/
variable "subnets" {
  type = list(object({
    subnet_name           = string
    subnet_ip_range       = string
    subnet_region         = string
    subnet_private_access = bool
    subnet_flow_logs      = bool
    description           = string
    secondary_ip_ranges   = any
  }))
  description = "The list of subnets being created"
}

# variable "secondary_ranges" {
#   type        = map(list(object({ range_name = string, ip_cidr_range = string })))
#   description = "Secondary ranges that will be used in some of the subnets"
#   default     = {}
# }

variable "routes" {
  type        = list(map(string))
  description = "List of routes being created in this VPC"
  default     = []
}

/******************************************
	3. Cloud NAT
 *****************************************/
variable "cloud_nat" {
  type = object({
    source_subnetwork_ip_ranges_to_nat = string
    log_config_enable                  = bool
    nat_log_config_filter              = string
  })
  description = "NAT and its logs configs"
  default = {
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    log_config_enable                  = false
    nat_log_config_filter              = "ALL"
  }
}

/******************************************
	4. Firewall Rules
 *****************************************/
variable "firewall_rules" {
  type = list(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    source_ranges           = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
    log_config = object({
      metadata = string
    })
  }))
}
