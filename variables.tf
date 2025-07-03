variable "project_id" {
  description = "GCP Project ID"
}

variable "certificate_environment" {
  description = "Certificate environment to use: 'staging' for testing (no rate limits) or 'production' for real deployments"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.certificate_environment)
    error_message = "certificate_environment must be either 'staging' or 'production'"
  }
}

variable "region" {
  description = "GCP Region"
  default     = "us-west2"
}

variable "postgres_username" {
  description = "PostgreSQL Username"
  default     = "tfeadmin"
}

variable "dns_hostname" {
  description = "DNS hostname for TFE"
  default     = "tfe"
}

variable "tfe_license" {
  description = "Base64 encoded TFE license"
  sensitive   = true
}

variable "certificate_email" {
  description = "Email address to register the Let's Encrypt certificate"
  type        = string
}

variable "tfe_version" {
  description = "TFE version to install"
  type        = string
  default     = "v202503-1"
}

locals {
  # Resource naming
  cluster_name = "tfe-cluster-gke"
  vpc_name     = "tfe-vpc-gke"
  subnet_name  = "tfe-subnet-gke"
  bucket_name  = "tfebucket-gke"
  tfe_hostname = trimsuffix("${var.dns_hostname}.${data.google_dns_managed_zone.existing_zones.dns_name}", ".")
  #tfe_hostname = trimsuffix("${var.dns_hostname}.${data.google_dns_managed_zones.existing_zones.managed_zones[0].dns_name}", ".")

  # Certificate server URL based on environment
  acme_server_url = var.certificate_environment == "staging" ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"
}

variable "gcp_credentials" {
  description = "GCP service account credentials (JSON) for Terraform Cloud"
  type        = string
  sensitive   = true
  default     = null
}
