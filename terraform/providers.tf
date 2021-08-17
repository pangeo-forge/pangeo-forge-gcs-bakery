terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}
provider "google" {
  project = var.project_name
  region  = "us-central1"
  zone    = "us-central1-c"
}
terraform {
  backend "gcs" {
    bucket  = "terraform-state"
    prefix  = "terraform/state"
  }
}