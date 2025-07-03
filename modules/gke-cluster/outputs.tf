output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "gke_cluster_region" {
  value = google_container_cluster.primary.location
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "gke_cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}
