locals {
  tw_microservice_sa=["mediawiki"]
}

/******************************************
	1. Namespaces Creation
 *****************************************/
resource "kubernetes_namespace" "tw_nginx" {
  for_each = toset(["ingress-nginx", "argocd", "mediawiki"])
  metadata {
    name = each.value
  }
  depends_on = [google_container_cluster.tw_gke_cluster, google_container_node_pool.tw_primary_nodepools]
}

/******************************************
	2. Service Account Creation
 *****************************************/
resource "kubernetes_service_account" "tw_namespace_sa" {
  for_each = toset(["mediawiki"])
  metadata {
    name      = each.value
    namespace = "mediawiki"
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.workload_identity_email}@${var.project_id}.iam.gserviceaccount.com"
    }
  }

  depends_on = [
    google_container_cluster.tw_gke_cluster,
    google_container_node_pool.tw_primary_nodepools,
    kubernetes_namespace.tw_nginx
  ]
}

/******************************************
	3. Wokload Identity Fedration
 *****************************************/
resource "google_service_account_iam_member" "k8s_workload_identity" {
  for_each           = toset(local.tw_microservice_sa)
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.workload_identity_email}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[mediawiki/${each.value}]"
  depends_on         = [google_container_cluster.tw_gke_cluster, google_container_node_pool.tw_primary_nodepools, kubernetes_service_account.tw_namespace_sa]
}

/******************************************
	4. Reserve IP for Load balancer
 *****************************************/
resource "google_compute_address" "tw_nginx_ip" {
  name         = "ingress-nginx"
  project      = var.project_id
  region       = var.region
  address_type = var.ingress_type == "public" ? "EXTERNAL" : "INTERNAL"
  subnetwork   = var.ingress_type == "public" ? null : var.subnetwork
  depends_on   = [google_container_cluster.tw_gke_cluster]
}

/******************************************
	5. Helm release Nginx Ingress Controller
 *****************************************/

resource "helm_release" "tw_nginx_helm_release" {
  provider   = helm
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.6.0"
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  # reuse_values = true
  max_history      = 1
  create_namespace = true
  timeout          = 300
  values = [templatefile("${path.module}/helm-values/nginx-values.yaml.tpl", {
    NGINX_IP     = "${google_compute_address.tw_nginx_ip.address}"
    MIN_REPLICAS = 2
    INGRESS_TYPE = "${var.ingress_type}" == "public" ? "External" : "Internal"
  })]
  depends_on = [
    google_compute_address.tw_nginx_ip,
    google_container_cluster.tw_gke_cluster,
    kubernetes_namespace.tw_nginx
  ]
}

## Argo CD Release
# resource "helm_release" "tw_argocd_helm_release" {
#   provider   = helm
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   version    = "4.9.7"
#   name       = "argocd"
#   namespace  = "argocd"
#   # reuse_values = true
#   max_history      = 1
#   create_namespace = true
#   timeout          = 300
#   values = [templatefile("${path.module}/helm-values/argo-values.yaml.tpl", {
#     INGRESS_HOST       = "argocd-${var.project_id}-${var.org_id}.tw.cloud"
#     INGRESS_TLS_SECRET = "argo-tls"
#     REPO_URL           = "https://github.com/LambdatestIncPrivate/tw-base-deployment"
#     REPO_PATH          = "microservices/overlays/gcp/tw-demo"
#     PROJECT_ID         = "${var.project_id}"
#   })]
#   depends_on = [
#     google_compute_address.tw_nginx_ip,
#     google_container_cluster.tw_gke_cluster,
#     kubernetes_namespace.tw_nginx
#   ]
# }

## Helm release MediaWiki
resource "helm_release" "mediawiki" {
  chart            = "mediawiki"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "20.0.4"
  name             = "mediawiki"
  namespace        = "mediawiki"
  create_namespace = true
  timeout          = 600
  values = [templatefile("${path.module}/helm-values/mediawiki-values.yaml.tpl", {
    MEDIAWIKI_USER = "user"
    MEDIAWIKI_PASS = "7A91aL7I9kHy"
    MEDIAWIKI_EMAIL = "soumilk.k@gmail.com"
    MARIADB_HOST = "mariadb.mediawiki.svc.cluster.local"
    MARIADB_USER = "root"
    MARIADB_PASS = "adminpass"
    MARIADB_DB = "mediawiki"
    LOAD_BALANCER_IP=""
  })]
  depends_on = [
    google_container_cluster.tw_gke_cluster,
    google_container_node_pool.tw_primary_nodepools,
    kubernetes_namespace.tw_nginx
    helm_release.mariadb
  ]
}

## Helm release MariaDB
resource "helm_release" "mariadb" {
  chart            = "mariadb"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "18.0.5"
  name             = "mariadb"
  namespace        = "mediawiki"
  create_namespace = true
  timeout          = 600
  values = [templatefile("${path.module}/helm-values/mariadb-values.yaml.tpl", {
    MARIADB_USER = "root"
    MARIADB_PASS = "adminpass"
    MARIADB_DB = "mediawiki"
  })]
  depends_on = [
    google_container_cluster.tw_gke_cluster,
    google_container_node_pool.tw_primary_nodepools,
    kubernetes_namespace.tw_nginx
  ]
}