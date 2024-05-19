# provider "google" {
#   region      = "asia-south2"
#   project     = "tcb-project-371706"
#   credentials = file("tcb-project-371706-b114ce01e529.json")
#   zone        = "asia-south2-a"
# }

terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "tw-infra-tfstate-tw-cgi-updated-tests"
    prefix = "service-account-tfstate/"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.59"
    }

    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 4.59"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "provider" {}
