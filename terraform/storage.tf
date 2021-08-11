resource "google_storage_bucket" "storage-bucket" {
  name          = "pangeo-forge-bakery-bucket"
  location      = "us"
  force_destroy = true
}

resource "google_service_account" "storage" {
  account_id   = "alexs-test-number-2"
  display_name = "Alex Bush Test Service Account"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:${google_service_account.storage.email}",
      "user:alexbush@developmentseed.org"
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket = google_storage_bucket.storage-bucket.name
  policy_data = data.google_iam_policy.admin.policy_data
}