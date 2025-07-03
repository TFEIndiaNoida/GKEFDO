variable "project_id" {
  description = "GCP Project ID"
}

variable "initial_node_count" {
  description = "Initial number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "node_pool_count" {
  description = "Number of nodes per zone in the primary node pool"
  type        = number
  default     = 1
}

variable "region" {
  description = "GCP Region"
}

variable "vpc_name" {
  description = "VPC name for the GKE cluster"
  type        = string
}

variable "subnet_name" {
  description = "Subnetwork name for the GKE cluster"
  type        = string
}

variable "acme_server_url" {
  description = "ACME server URL for Let's Encrypt"
  type        = string
}

variable "certificate_email" {
  description = "Email address to register the Let's Encrypt certificate"
  type        = string
}
