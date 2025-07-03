resource "google_service_account" "cert-manager" {
  account_id   = "cert-manager"
  display_name = "cert-manager"
  project      = var.project_id
}

resource "google_project_iam_member" "cert-manager-role-binding" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert-manager.email}"
}

resource "google_project_iam_member" "cert-manager-k8s-workload-identity-binding" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"

  depends_on = [google_container_cluster.primary]
}

resource "google_project_iam_member" "cert-manager-workload-identity-binding" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.cert-manager.email}"
}

resource "google_project_iam_member" "cert-manager-service-account-token-creator-role" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.cert-manager.email}"
}

resource "google_service_account" "external-dns" {
  account_id   = "external-dns"
  display_name = "external-dns"
  project      = var.project_id
}


resource "google_project_iam_member" "external-dns-role-binding" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external-dns.email}"
}

resource "google_project_iam_member" "external-dns-k8s-workload-identity-binding" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"

  depends_on = [google_container_cluster.primary]
}

resource "google_project_iam_member" "external-dns-workload-identity-binding" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.external-dns.email}"
}

resource "google_project_iam_member" "external-dns-service-account-token-creator-role" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.external-dns.email}"
}
