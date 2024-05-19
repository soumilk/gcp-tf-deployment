data "google_project" "project" {
  project_id = var.project_id
}

module "tw_networking" {
  source                                     = "./vpc"
  project_id                                 = var.project_id
  region                                     = var.region
  vpc_name                                   = var.vpc_name
  vpc_auto_create_subnetworks                = var.vpc_auto_create_subnetworks
  vpc_routing_mode                           = var.vpc_routing_mode
  vpc_description                            = var.vpc_description
  vpc_delete_default_internet_gateway_routes = var.vpc_delete_default_internet_gateway_routes
  subnets                                    = var.subnets
  cloud_nat                                  = var.cloud_nat
  firewall_rules                             = var.firewall_rules
}
