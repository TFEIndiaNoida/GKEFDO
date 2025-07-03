resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
}

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }

  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
}
