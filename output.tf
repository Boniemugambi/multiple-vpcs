# This file outputs the values that will be used in other modules. It's used by:
#           1: network_peering module to collect the values for networks to be peered.

output "mynetwork1" {
  value = google_compute_network.mynetwork.self_link
  description = "output for the network ' mynetwork' "
}

output "privatenet" {
  value = google_compute_network.privatenet.self_link
  description = "output for the network ' mynetwork' "
}

# output "management-subnet" {
#     value = google_compute_subnetwork.managementsubnet-us.self_link
#     description = "output for the management-us subnet"
# }