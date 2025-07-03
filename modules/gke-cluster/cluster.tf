# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # We use a separately managed node pool
  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count

  # Disable deletion protection
  deletion_protection = false

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Add TLS configuration
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Add certificate configuration
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_pool_count

  lifecycle {
    create_before_destroy = true
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    machine_type = "e2-standard-2"
    tags         = ["gke-node", "${var.project_id}-gke"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
