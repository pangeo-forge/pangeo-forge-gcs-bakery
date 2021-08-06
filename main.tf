resource "google_service_account" "alex_test" {
  account_id   = "serviceaccountid"
  display_name = "Alex B Test Service Account"
}

resource "google_compute_instance" "default" {
  name         = "test-alex"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["alexb-test",]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    type = "alexs_test_machine"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.alex_test.email
    scopes = ["cloud-platform"]
  }
}