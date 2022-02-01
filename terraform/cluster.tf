data "google_project" "project" {
}

resource "google_service_account" "cluster" {
  account_id   = var.cluster_service_account_name
  display_name = "PangeoForge GCS Bakery Cluster Service Account"
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_region
  project  = var.project_name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  resource_labels          = local.tags

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
      ip_allocation_policy
    ]
  }

  /**
  * Following private cluster config adapted from 2i2c:
  * https://github.com/2i2c-org/infrastructure/pull/538/files
  */

  // For private clusters, pass the name of the network and subnetwork created
  // by the VPC
  network    = var.enable_private_cluster ? data.google_compute_network.default_network.name : null
  subnetwork = var.enable_private_cluster ? data.google_compute_subnetwork.default_subnetwork.name : null

  // Dynamically provision the private cluster config when deploying a
  // private cluster
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []

    content {
      // Decide if this CIDR block is sensible or not
      master_ipv4_cidr_block  = "172.16.0.0/28"
      enable_private_nodes    = true
      enable_private_endpoint = false
    }
  }

  // Dynamically provision the IP allocation policy when deploying a
  // private cluster. This allows for IP aliasing and makes the cluster
  // VPC-native
  dynamic "ip_allocation_policy" {
    for_each = var.enable_private_cluster ? [1] : []
    content {}
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "alex-bush-node-pool"
  location   = var.cluster_region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config
    ]
  }

  node_config {
    preemptible  = true
    machine_type = "e2-standard-4"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}