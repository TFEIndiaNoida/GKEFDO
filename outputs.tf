# Output values to be used by deployment script
output "gke_cluster_name" {
  value = module.gke-cluster.gke_cluster_name
}

output "gke_cluster_region" {
  value = module.gke-cluster.gke_cluster_region
}

output "postgres_private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "postgres_public_ip" {
  value = google_sql_database_instance.postgres.public_ip_address
}

output "redis_host" {
  value = google_redis_instance.redis.host
}

output "redis_port" {
  value = google_redis_instance.redis.port
}

output "tfe_hostname" {
  value = local.tfe_hostname
}

output "project_id" {
  value = var.project_id
}

output "tfe_encryption_password" {
  value     = random_password.encryption-password.result
  sensitive = true
}

output "tfe_license" {
  value     = var.tfe_license
  sensitive = true
}

output "postgres_username" {
  value = var.postgres_username
}

output "postgres_password" {
  value     = random_password.postgres-password.result
  sensitive = true
}

output "certificate_email" {
  value = var.certificate_email
}

output "tfe_version" {
  value = var.tfe_version
}

output "admin_user" {
  description = "URL to create the initial admin user."
  value       = "https://${local.tfe_hostname}/admin/account/new?token=${random_password.iact-token.result}"
  sensitive   = true
}
