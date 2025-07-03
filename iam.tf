# Service account for TFE GCS bucket access
resource "google_service_account" "tfe" {
  account_id   = "terraform-enterprise"
  display_name = "terraform-enterprise"
  project      = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Grant storage admin permissions to the service account
resource "google_project_iam_member" "tfe_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.tfe.email}"
}

# Grant composer environment and storage object admin permissions
resource "google_project_iam_member" "tfe_composer_admin" {
  project = var.project_id
  role    = "roles/composer.environmentAndStorageObjectAdmin"
  member  = "serviceAccount:${google_service_account.tfe.email}"
}

resource "google_project_iam_member" "tfe-k8s-workload-identity" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.tfe.metadata[0].name}/terraform-enterprise]"

  depends_on = [module.gke-cluster]
}

resource "google_project_iam_member" "tfe-workload-identity" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.tfe.email}"
}

resource "google_project_iam_member" "tfe-service-account-token-creator-role" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.tfe.email}"
}
