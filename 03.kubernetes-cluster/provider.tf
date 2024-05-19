
terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "tw-infra-tfstate-tw-cgi-updated-tests"
    prefix = "kubernetes-cluster-tfstate/"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.59"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.59"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  # impersonate_service_account = var.tf_google_provider_skip_impersonation == "" ? (var.tf_google_provider_service_account != "" ? var.tf_google_provider_service_account : null) : null
}

provider "helm" {
  kubernetes {
    host                   = module.tw_gke.endpoint
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = module.tw_gke.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host                   = "https://${module.tw_gke.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = module.tw_gke.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.tw_gke.endpoint
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = module.tw_gke.cluster_ca_certificate
}
data "google_client_config" "provider" {}
