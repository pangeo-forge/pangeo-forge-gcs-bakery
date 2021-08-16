data "google_project" "project" {
}

resource "google_service_account" "cluster" {
  account_id   = var.cluster_service_account_name
  display_name = "PangeoForge GCS Bakery Cluster Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "alex-bush-gke-cluster"
  location = "us-west1-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "alex-bush-node-pool"
  location   = "us-west1-a"
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
    tags = flatten(local.tags)
    preemptible  = true
    machine_type = "e2-standard-4"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes2" {
  name       = "alex-bush-node-pool2"
  location   = "us-east1-a"
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
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_region" {
  value = google_container_cluster.primary.location
}

output "cluster_project" {
  value = "pangeo-forge-bakery-gcp"
}