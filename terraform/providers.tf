terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.9.0"
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
    bucket = "terraform-tfstate-gcp"
    prefix = "terraform/state"
  }
}