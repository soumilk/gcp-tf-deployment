/******************************************
	1. VPC configuration
 *****************************************/
output "network" {
  value       = google_compute_network.tw_vpc
  description = "The VPC resource being created"
}

output "network_name" {
  value       = google_compute_network.tw_vpc.name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = google_compute_network.tw_vpc.id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = google_compute_network.tw_vpc.self_link
  description = "The URI of the VPC being created"
}

/******************************************
	2. Subnet configuration
 *****************************************/


output "id" {
  value = { for subnet in google_compute_subnetwork.tw_vpc_subnets: subnet.id => subnet.id }
  description = "An identifier for the resource with format projects/{{project}}/regions/{{region}}/subnetworks/{{name}}"
} 

output "gateway_address"{
  value = { for subnet in google_compute_subnetwork.tw_vpc_subnets: subnet.id => subnet.gateway_address }
  description = "The gateway address for default routes to reach destination addresses outside this subnetwork."
} 

output "self_link" {
  value = { for subnet in google_compute_subnetwork.tw_vpc_subnets: subnet.id => subnet.self_link }
  description = "The URI of the created resource."
} 