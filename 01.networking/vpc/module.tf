/******************************************
	1. VPC configuration
 *****************************************/
resource "google_compute_network" "tw_vpc" {
  project                         = var.project_id
  name                            = var.vpc_name
  auto_create_subnetworks         = var.vpc_auto_create_subnetworks
  routing_mode                    = var.vpc_routing_mode
  description                     = var.vpc_description
  delete_default_routes_on_create = var.vpc_delete_default_internet_gateway_routes
}

/******************************************
	1.1 Shared VPC (Conditional)
 *****************************************/
resource "google_compute_shared_vpc_host_project" "tw_shared_vpc_host_project" {
  count      = var.shared_vpc_host_project ? 1 : 0
  project    = var.project_id
  depends_on = [google_compute_network.tw_vpc]
}

resource "google_compute_shared_vpc_service_project" "tw_shared_vpc_service_project" {
  count           = var.shared_vpc_service_project ? 1 : 0
  host_project    = var.shared_vpc_host_project_id
  service_project = var.project_id
}

/******************************************
	2. Subnet configuration
 *****************************************/
resource "google_compute_subnetwork" "tw_vpc_subnets" {
  for_each                 = { for u in var.subnets : u.subnet_name => u }
  project                  = var.project_id
  name                     = each.value.subnet_name
  ip_cidr_range            = each.value.subnet_ip_range
  region                   = each.value.subnet_region
  role                     = "ACTIVE"
  network                  = google_compute_network.tw_vpc.id
  private_ip_google_access = true
  description              = lookup(each.value, "description", null)

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ip_ranges", null)

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = lookup(each.value, "subnet_flow_logs", false) ? [{
      aggregation_interval = lookup(each.value, "subnet_flow_logs_interval", "INTERVAL_1_MIN")
      flow_sampling        = lookup(each.value, "subnet_flow_logs_sampling", "0.5")
      metadata             = lookup(each.value, "subnet_flow_logs_metadata", "INCLUDE_ALL_METADATA")
    }] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
    }
  }
}

/******************************************
	3. Cloud NAT
 *****************************************/
resource "google_compute_router" "tw_router_region" {
  name    = "${google_compute_network.tw_vpc.name}-${var.region}-router"
  network = google_compute_network.tw_vpc.id
  project = var.project_id
  region  = var.region
}

resource "google_compute_address" "tw_router_nat_ip" {
  name   = "${google_compute_router.tw_router_region.name}-ip"
  region = var.region
}

resource "google_compute_router_nat" "tw_router_nat_region" {
  name                               = "${google_compute_router.tw_router_region.name}-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.tw_router_region.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.tw_router_nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = lookup(var.cloud_nat, "source_subnetwork_ip_ranges_to_nat", "ALL_SUBNETWORKS_ALL_IP_RANGES")
  log_config {
    enable = lookup(var.cloud_nat, "nat_log_config_enable", false)
    filter = lookup(var.cloud_nat, "nat_log_config_filter", "ALL")
  }
}

/******************************************
	4. VPC Firewall Rules
 *****************************************/
resource "google_compute_firewall" "tw_rules_ingress_egress" {
  for_each                = length(var.firewall_rules) > 0 ? { for r in var.firewall_rules : r.name => r } : {}
  project                 = var.project_id
  name                    = each.value.name
  description             = each.value.description
  direction               = each.value.direction
  network                 = google_compute_network.tw_vpc.id
  source_ranges           = lookup(each.value, "source_ranges", null)
  destination_ranges      = lookup(each.value, "destination_ranges", null)
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
  priority                = each.value.priority

  dynamic "log_config" {
    for_each = lookup(each.value, "log_config") == null ? [] : [each.value.log_config]
    content {
      metadata = log_config.value.metadata
    }
  }

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
  depends_on = [ google_compute_network.tw_vpc ]
}
