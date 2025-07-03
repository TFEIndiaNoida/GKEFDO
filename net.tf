############### NETWORKING RESOURCES ###############

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required_apis
  ]
}

# Subnet for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

  private_ip_google_access = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  name    = "gke-nat-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "gke-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Global IP address for private services access
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# Service Networking Connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  deletion_policy = "ABANDON"

  depends_on = [
    google_project_service.required_apis,
  ]
}

# Firewall Rules
resource "google_compute_firewall" "tfe_ingress" {
  name    = "tfe-ingress-rules"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443", "5432", "8201", "6379"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

# Create specific egress rules for the database and Redis subnets
resource "google_compute_firewall" "tfe_sql_egress" {
  name    = "allow-sql-egress"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  direction          = "EGRESS"
  destination_ranges = ["10.77.80.0/24"] # PostgreSQL subnet
}

resource "google_compute_firewall" "tfe_redis_egress" {
  name    = "allow-redis-egress"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  direction          = "EGRESS"
  destination_ranges = ["10.77.81.0/29"] # Redis subnet
}
