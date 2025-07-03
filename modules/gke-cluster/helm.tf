############### Helm Releases ###############

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.17.2"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  values = [
    yamlencode({
      installCRDs = true
      extraArgs = [
        "--dns01-recursive-nameservers-only",
        "--dns01-recursive-nameservers=1.1.1.1:53,8.8.8.8:53",
      ]
      serviceAccount = {
        create = true
        annotations = {
          "iam.gke.io/gcp-service-account" = google_service_account.cert-manager.email
        }
      }
    })
  ]
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.2"
  namespace  = kubernetes_namespace.ingress-nginx.metadata[0].name
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.16.1"
  namespace  = kubernetes_namespace.external-dns.metadata[0].name

  values = [
    yamlencode({
      extraArgs = [
        "--txt-prefix=extdns-%%{record_type}."
      ]
      provider = {
        name = "google"
      }
      interval           = "1h"
      triggerLoopOnEvent = true
      policy             = "sync"

      serviceAccount = {
        create = true
        annotations = {
          "iam.gke.io/gcp-service-account" = google_service_account.external-dns.email
        }
      }
    })
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01
spec:
  acme:
    server: ${var.acme_server_url}
    email: ${var.certificate_email}
    privateKeySecretRef:
      name: letsencrypt-dns01
    solvers:
      - dns01:
          cloudDNS:
            project: ${var.project_id}
YAML

  depends_on = [helm_release.cert-manager]
}

