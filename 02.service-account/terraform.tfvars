
project_id = "<project_id>"
region     = "asia-south1"
gcp_service_accounts_list = [
  {
    display_name = "tw-gke-cluster-sa"
    name         = "tw-gke"
    description  = "The service account used by the GKE Nodepools"
    project_roles = [
      "roles/compute.viewer",
      "roles/logging.logWriter",
      "roles/pubsub.subscriber",
      "roles/iam.serviceAccountTokenCreator",
      "roles/monitoring.metricWriter",
      "roles/monitoring.viewer",
      "roles/stackdriver.resourceMetadata.writer",
      "roles/logging.admin",
      "roles/artifactregistry.reader"
    ]
  },
  {
    display_name = "tw-gke-workload-identity-sa"
    name         = "tw-gke-workload-identity"
    description  = "The service account used by the Application workloads for workload identity, the workloads require access to storage, pubsub, redis and secret manager"
    project_roles = [
      "roles/storage.objectViewer",
      "roles/storage.objectCreator",
      "roles/storage.objectViewer",
      "roles/compute.viewer",
      "roles/logging.logWriter",
      "roles/iam.serviceAccountTokenCreator",
      "roles/container.developer",
      "roles/artifactregistry.reader",
    ]
  }
]


## NOTE: In case of the shared VPC, there will be some extra permissions required

#container.clusters.get permission is required for the bastion