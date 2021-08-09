terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}
provider "google" {
  project = "pangeo-forge-bakery-gcp"
  region = "us-central1"
  zone = "us-central1-c"
}
