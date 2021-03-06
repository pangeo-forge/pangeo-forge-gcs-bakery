resource "google_storage_bucket" "storage-bucket" {
  name          = var.storage_name
  location      = "us"
  force_destroy = true
}

resource "google_service_account" "storage" {
  account_id   = var.storage_service_account_name
  display_name = "PangeoForge GCS Bakery Storage Service Account"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:${google_service_account.storage.email}",
      "serviceAccount:${google_service_account.cluster.email}",
      "user:alexbush@developmentseed.org"
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.storage-bucket.name
  policy_data = data.google_iam_policy.admin.policy_data
}