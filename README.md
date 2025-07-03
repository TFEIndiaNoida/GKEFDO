
# Terraform Enterprise on GKE

This repository sets up Terraform Enterprise (TFE) on Google Kubernetes Engine (GKE) in Google Cloud Platform (GCP).

Note to self to properly link and credit Patrick Munne & whoever else helped write the GCP openshift doc as I used it extensively to build this.

## Setup Process

Before starting, you will need a GCP Project, a service account, and credentials. 

1. Request GCP project through doormat
    1. Must set DNS option, recommend account-id though the other option -should- work. If you don't see a zone in your GCP account, you probably missed this and will need to request a new one
    2. Verify you can access console through doormat to ensure account is set up
    3. Do this first as it will take some time to set up
    4. Once console is accessible, search for cloud dns and take note of your domain

2. Set up GCP service account for Terraform Cloud
instructions for installing gcloud cli
gcloud auth login 
gcloud auth application-default login 
gcloud config set project $PROJID
gcloud iam service-accounts create terraform-cloud --display-name="Terraform Cloud Service Account"
gcloud projects add-iam-policy-binding hc-8cd228781899442fa5090750bb8 \
  --member='serviceAccount:hc-8cd228781899442fa5090750bb8@appspot.gserviceaccount.com' \
  --role='roles/cloudsql.admin'
gcloud iam service-accounts keys create ~/Desktop/gcp-credentials.json --iam-account=terraform-cloud@$(gcloud config get-value project).iam.gserviceaccount.com
gcloud auth activate-service-account --key-file=~/Desktop/gcp-credentials.json

3. How to
Clone the repository to your local machine
git clone https://github.com/TFEIndiaNoida/GKEFDO.git

terraform init
Terraform plan
terraform apply

4. What Happens After Apply
GKE Cluster, NGINX Ingress, TFE, and ExternalDNS are deployed.
TFE Helm chart creates an Ingress resource for your chosen hostname (e.g., tfe.hc-8cd228781899442fa5090750bb8.gcp.sbx.hashicorpdemo.com).
NGINX Ingress controller provisions a public LoadBalancer IP.
ExternalDNS detects the Ingress and automatically creates an A record in your Google Cloud DNS zone, mapping your hostname to the LoadBalancer IP.

5. It should output the resources as below

Outputs:

admin_user = <sensitive>
certificate_email = "ramit.bansal@hashicorp.com"
gke_cluster_name = "hc-8cd228781899442fa5090750bb8-gke"
gke_cluster_region = "us-west2"
postgres_password = <sensitive>
postgres_private_ip = "172.25.1.3"
postgres_public_ip = ""
postgres_username = "tfeadmin"
project_id = "hc-8cd228781899442fa5090750bb8"
redis_host = "172.25.0.3"
redis_port = 6379
tfe_encryption_password = <sensitive>
tfe_hostname = "tfe.hc-8cd228781899442fa5090750bb8.gcp.sbx.hashicorpdemo.com"
tfe_license = <sensitive>
tfe_version = "v202503-1"

5. Hit the url as mentioned in tfe_hostname   

