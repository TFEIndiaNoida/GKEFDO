
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

   gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
     --member="serviceAccount:terraform-cloud@$(gcloud config get-value project).iam.gserviceaccount.com" \
     --role="roles/owner"

   gcloud iam service-accounts keys create ~/Desktop/gcp-credentials.json \
     --iam-account=terraform-cloud@$(gcloud config get-value project).iam.gserviceaccount.com

Navigate to https://app.terraform.io/app/hashicorp-support-eng/registry/modules/private/hashicorp-support-eng/gke-fdo/gcp/2.0.0
Click on Provision Workspace on the top right.
Configure the module inputs.
Click on Next: Workspace settings.
Provide a name for your workspace.
If desired, select a Project to associate with this workspace.
Optionally, enter a description and choose your apply method.
Click on Create workspace to finalize the setup.
