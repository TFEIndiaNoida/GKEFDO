Terraform Enterprise on GKE
Provision Terraform Enterprise (TFE) on Google Kubernetes Engine (GKE) in Google Cloud Platform (GCP) with automated DNS, TLS, and production best practices.

Setup Process

1. Request GCP Project & DNS

2. Set Up GCP Service Account

3. Clone and Deploy

4. What Happens After Apply

5. Outputs

6. Accessing TFE

This repository automates the deployment of Terraform Enterprise (TFE) on a secure, production-ready GKE cluster, with:
Automated networking, IAM, storage, and secrets
Automated public DNS and TLS (Let’s Encrypt)
Zero manual steps after terraform apply

Prerequisites
Access to a GCP Project (with Cloud DNS zone)
gcloud CLI
Terraform 1.3+
TFE License file

Setup Process
1. Request GCP Project & DNS
Request your GCP project (e.g., via Doormat or your internal process).
Choose the DNS option (recommended: account-id).
Verify Cloud DNS zone is created in your project (e.g., hc-xxxx.gcp.sbx.hashicorpdemo.com).
Access GCP Console to confirm setup.

2. Set Up GCP Service Account
Generate a service account and credentials for Terraform:

# Authenticate with gcloud (user account)
gcloud auth login

# Set your project
gcloud config set project $PROJID

# Create a service account for Terraform
gcloud iam service-accounts create terraform-cloud \
  --display-name="Terraform Cloud Service Account"

# Grant required IAM roles (example: Cloud SQL Admin)
gcloud projects add-iam-policy-binding $PROJID \
  --member="serviceAccount:terraform-cloud@$PROJID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

# Generate and download service account key
gcloud iam service-accounts keys create ~/Desktop/gcp-credentials.json \
  --iam-account=terraform-cloud@$PROJID.iam.gserviceaccount.com

# Activate service account for gcloud CLI usage
gcloud auth activate-service-account --key-file=~/Desktop/gcp-credentials.json

3. Clone and Deploy
# Clone this repository
git clone https://github.com/TFEIndiaNoida/GKEFDO.git

cd GKEFDO

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

4. What Happens After Apply

GKE Cluster, NGINX Ingress, TFE, and ExternalDNS are deployed.

TFE Helm chart creates an Ingress for your hostname (e.g., tfe.hc-xxxx.gcp.sbx.hashicorpdemo.com).

NGINX Ingress provisions a public LoadBalancer IP.

ExternalDNS automatically creates an A record in Cloud DNS, mapping your hostname to the LoadBalancer IP.

Cert-manager issues a TLS certificate via Let’s Encrypt.

5. Outputs
After a successful apply, you’ll see outputs similar to:


admin_user                = <sensitive>

certificate_email         = "ramit.bansal@hashicorp.com"

gke_cluster_name          = "hc-xxxx-gke"

gke_cluster_region        = "us-west2"

postgres_password         = <sensitive>

postgres_private_ip       = "172.25.1.3"

postgres_public_ip        = ""

postgres_username         = "tfeadmin"

project_id                = "hc-xxxx"

redis_host                = "172.25.0.3"

redis_port                = 6379

tfe_encryption_password   = <sensitive>

tfe_hostname              = "tfe.hc-xxxx.gcp.sbx.hashicorpdemo.com"

tfe_license               = <sensitive>

tfe_version               = "v202503-1"

6. Accessing TFE
Open your browser and navigate to the URL shown in tfe_hostname output.

Log in and complete the Terraform Enterprise setup.
