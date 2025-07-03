provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.gcp_credentials
}

provider "kubernetes" {
  host                   = "https://${module.gke-cluster.gke_cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke-cluster.gke_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke-cluster.gke_cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke-cluster.gke_cluster_ca_certificate)
  }
}

# Needed to be able to use CRDs that aren't already in the cluster at plan time.
provider "kubectl" {
  host                   = "https://${module.gke-cluster.gke_cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke-cluster.gke_cluster_ca_certificate)
  load_config_file       = false
}

data "google_client_config" "default" {}

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    # Needed to be able to use CRDs that aren't already in the cluster at plan time.
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
