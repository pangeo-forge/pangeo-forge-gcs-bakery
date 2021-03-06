/**
* Networking to support private clusters. This config is only deployed when the
* enable_private_cluster variable is set to true.
* Adapted from 2i2c: https://github.com/2i2c-org/infrastructure/pull/538/files
*/

data "google_compute_network" "default_network" {
  name    = "default"
  project = var.project_name
}

data "google_compute_subnetwork" "default_subnetwork" {
  name    = "default"
  project = var.project_name
  region  = var.cluster_region
}

resource "google_compute_firewall" "iap_ssh_ingress" {
  count = var.enable_private_cluster ? 1 : 0

  name    = "allow-ssh"
  project = var.project_name
  network = data.google_compute_network.default_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  // This range contains all IP addresses that IAP uses for TCP forwarding.
  // https://cloud.google.com/iap/docs/using-tcp-forwarding
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_router" "router" {
  count = var.enable_private_cluster ? 1 : 0

  name    = "${var.project_name}-router"
  project = var.project_name
  region  = var.cluster_region
  network = data.google_compute_network.default_network.id
}

resource "google_compute_router_nat" "nat" {
  count = var.enable_private_cluster ? 1 : 0

  name                               = "${var.project_name}-router-nat"
  project                            = var.project_name
  region                             = var.cluster_region
  router                             = google_compute_router.router[0].name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  // Set these values explicitly so they don't "change outside terraform"
  nat_ips       = []
  drain_nat_ips = []
}