/******************************************
  1. GKE Cluster
 *****************************************/
resource "google_container_cluster" "tw_gke_cluster" {
  project            = var.project_id
  name               = var.name
  location           = var.regional ? var.region : "${var.region}-a"
  node_locations     = var.regional ? ["${var.region}-a", "${var.region}-b"] : ["${var.region}-a"]
  description        = var.description
  resource_labels    = var.cluster_resource_labels
  initial_node_count = 1

  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  network           = var.network

  release_channel {
    channel = var.release_channel
  }

  subnetwork = var.subnetwork

  # default_snat_status {
  #   disabled = var.disable_default_snat
  # }

  # min_master_version = "1.X.Y-.*"
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }
  default_max_pods_per_node = var.default_max_pods_per_node
  enable_shielded_nodes     = var.enable_shielded_nodes

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) == 0 ? [] : [{
      cidr_blocks : var.master_authorized_networks
    }]
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  addons_config {
    http_load_balancing {
      disabled = !var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }
    #This must be enabled in order to enable network policy for the nodes. To enable this, you must also define a network_policy block, otherwise nothing will happen
    network_policy_config {
      disabled = !var.network_policy
    }
  }

  datapath_provider = var.datapath_provider

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
    stack_type                    = "IPV4"
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count, resource_labels]
  }

  dynamic "dns_config" {
    for_each = var.cluster_dns_provider == "CLOUD_DNS" ? [1] : []
    content {
      cluster_dns        = var.cluster_dns_provider
      cluster_dns_scope  = var.cluster_dns_scope
      cluster_dns_domain = var.cluster_dns_domain
    }
  }

  remove_default_node_pool = var.remove_default_node_pool

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  dynamic "authenticator_groups_config" {
    for_each = var.authenticator_security_group == null ? [] : [{
      security_group = var.authenticator_security_group
    }]
    content {
      security_group = authenticator_groups_config.value.security_group
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", "45m")
    update = lookup(var.timeouts, "update", "45m")
    delete = lookup(var.timeouts, "delete", "45m")
  }
}

/******************************************
  1. GKE Cluster Node Pools
 *****************************************/
resource "google_container_node_pool" "tw_primary_nodepools" {
  for_each       = { for x in var.node_pools : x.name => x }
  project        = var.project_id
  location       = var.region
  name           = each.value.name
  node_locations = ["${var.region}-a"]

  cluster = google_container_cluster.tw_gke_cluster.name

  # version = lookup(each.value, "auto_upgrade", local.default_auto_upgrade) ? "" : lookup(
  #   each.value,
  #   "version",
  #   google_container_cluster.tw_gke_cluster.min_master_version,
  # )
  max_pods_per_node = lookup(each.value, "max_pods_per_node", 35)
  node_count        = lookup(each.value, "initial_node_count", 1)

  autoscaling {
    min_node_count = lookup(each.value, "min_count", 1)
    max_node_count = lookup(each.value, "max_count", 10)
  }

  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  upgrade_settings {
    max_surge       = lookup(each.value, "max_surge", 2)
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }

  node_config {
    # boot_disk_kms_key = var.boot_disk_kms_key
    image_type   = each.value.image_type
    machine_type = each.value.machine_type
    labels = merge(
      each.value.labels,
      { "cluster_name" = var.name }
    )
    metadata = {
      "disable-legacy-endpoints" = var.disable_legacy_metadata_endpoints
    }
    dynamic "taint" {
      for_each = length(each.value.taints) > 0 ? each.value.taints : []
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }
    gvnic {
      enabled = lookup(each.value, "enable_gvnic", var.enable_gvnic)
    }

    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")
    tags            = var.tags


    service_account = "${each.value.service_account}@${var.project_id}.iam.gserviceaccount.com"
    preemptible     = lookup(each.value, "preemptible", false)

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    # dynamic "workload_metadata_config" {
    #   for_each = local.cluster_node_metadata_config

    #   content {
    #     mode = lookup(each.value, "node_metadata", workload_metadata_config.value.mode)
    #   }
    # }

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count, node_count]
  }

  timeouts {
    create = lookup(var.timeouts, "create", "45m")
    update = lookup(var.timeouts, "update", "45m")
    delete = lookup(var.timeouts, "delete", "45m")
  }
}

locals {
  gke_cluster_primary = google_container_cluster.tw_gke_cluster
}
