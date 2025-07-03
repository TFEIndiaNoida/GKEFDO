resource "kubernetes_namespace" "tfe" {
  metadata {
    name = "terraform-enterprise"
  }

  depends_on = [
    module.gke-cluster,
  ]
}

# Docker registry secret for HashiCorp registry
resource "kubernetes_secret" "docker_registry" {
  metadata {
    name      = "terraform-enterprise"
    namespace = kubernetes_namespace.tfe.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "images.releases.hashicorp.com" = {
          auth = base64encode("terraform:${var.tfe_license}")
        }
      }
    })
  }
}

resource "random_password" "encryption-password" {
  length  = 16
  special = true
}

resource "random_password" "postgres-password" {
  length  = 16
  special = true
}

resource "random_password" "iact-token" {
  length  = 16
  special = true
}

# TFE Helm Release
resource "helm_release" "tfe" {
  name       = "terraform-enterprise"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "terraform-enterprise"
  version    = "1.6.0"
  namespace  = kubernetes_namespace.tfe.metadata[0].name
  // Large timeout
  // It takes over 2 minutes to pull the image.
  // Certificate generation from cert-manager takes around 3 minutes
  // Migrations take > 3 minutes
  timeout = 600

  values = [
    yamlencode({
      env = {
        secrets = {
          TFE_DATABASE_PASSWORD   = random_password.postgres-password.result
          TFE_ENCRYPTION_PASSWORD = random_password.encryption-password.result
          TFE_LICENSE             = var.tfe_license
        }
        variables = {
          TFE_DATABASE_HOST                          = google_sql_database_instance.postgres.private_ip_address
          TFE_DATABASE_NAME                          = google_sql_database.database.name
          TFE_DATABASE_PARAMETERS                    = "sslmode=require"
          TFE_DATABASE_USER                          = google_sql_user.user.name
          TFE_HOSTNAME                               = local.tfe_hostname
          TFE_IACT_SUBNETS                           = "0.0.0.0/0"
          TFE_OBJECT_STORAGE_TYPE                    = "google"
          TFE_OBJECT_STORAGE_GOOGLE_BUCKET           = google_storage_bucket.tfe_bucket.name
          TFE_OBJECT_STORAGE_GOOGLE_PROJECT          = var.project_id
          TFE_REDIS_HOST                             = "${google_redis_instance.redis.host}:${google_redis_instance.redis.port}"
          TFE_RUN_PIPELINE_KUBERNETES_WORKER_TIMEOUT = "300"
          TFE_IACT_TOKEN                             = random_password.iact-token.result
        }
      }
      service = {
        type = "ClusterIP"
      }
      serviceAccount = {
        enabled = true
        name    = "terraform-enterprise"
        annotations = {
          "iam.gke.io/gcp-service-account" = "${google_service_account.tfe.email}"
        }
      }
      image = {
        name       = "hashicorp/terraform-enterprise"
        repository = "images.releases.hashicorp.com"
        tag        = var.tfe_version
        pullSecrets = [
          {
            name = kubernetes_secret.docker_registry.metadata[0].name
          }
        ]
      }
      tls = {
        secretName = "terraform-enterprise-certificates"
      }
      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          "nginx.ingress.kubernetes.io/proxy-body-size"  = "0"
          "cert-manager.io/cluster-issuer"               = "letsencrypt-dns01"
        }
        hosts = [
          {
            host = local.tfe_hostname
            paths = [
              {
                portNumber  = 443
                serviceName = "terraform-enterprise"
                path        = "/"
                pathType    = "Prefix"
              }
            ]
          }
        ]
        tls = [
          {
            hosts      = [local.tfe_hostname]
            secretName = "terraform-enterprise-certificates"
          }
        ]
      }
    })
  ]
}
