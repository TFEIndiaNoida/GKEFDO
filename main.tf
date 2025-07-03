# Enable required Google APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "cloudapis.googleapis.com",
    "servicemanagement.googleapis.com",
    "storage-api.googleapis.com",
    "storage.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "container.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  # Disable service disruption during disable
  disable_on_destroy = false
}

module "gke-cluster" {
  source            = "./modules/gke-cluster"
  project_id        = var.project_id
  region            = var.region
  vpc_name          = google_compute_network.vpc.name
  subnet_name       = google_compute_subnetwork.subnet.name
  acme_server_url   = local.acme_server_url
  certificate_email = var.certificate_email
}

# Reference existing DNS zone instead of creating a new one
data "google_dns_managed_zone" "existing_zones" {
  name    = "doormat-accountid"
  project = var.project_id

}

############### STORAGE RESOURCES ###############

# Create GCS bucket for object storage
resource "google_storage_bucket" "tfe_bucket" {
  name                        = "tfebucket-${var.project_id}"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
}

# PostgreSQL instance with explicit deletion handling
resource "google_sql_database_instance" "postgres" {
  name             = "tfe-postgresql"
  database_version = "POSTGRES_16"
  region           = var.region
  project          = var.project_id

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    tier = "db-perf-optimized-N-2"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }
    availability_type = "ZONAL"
  }

  deletion_protection = false

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true
  }
}

# Add explicit dependency for database and user
resource "google_sql_database" "database" {
  name     = "tfe"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "user" {
  name        = var.postgres_username
  instance    = google_sql_database_instance.postgres.name
  password = random_password.postgres-password.result

  deletion_policy = "ABANDON"
}

# Redis instance with explicit deletion handling
resource "google_redis_instance" "redis" {
  name           = "tfe-redis"
  tier           = "BASIC"
  memory_size_gb = 1
  region         = var.region
  project        = var.project_id

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  authorized_network = google_compute_network.vpc.self_link
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true
  }
}
