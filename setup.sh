echo "Enabling GCP APIs, please wait, this may take several minutes..."
echo "Storage API"...
gcloud services enable storage.googleapis.com
echo "Compute API"...
gcloud services enable compute.googleapis.com
echo "Artifact Registry API"...
gcloud services enable artifactregistry.googleapis.com
echo "Cloud Build API"...
gcloud services enable cloudbuild.googleapis.com
echo "Cloud Resource Manager API"...
gcloud services enable cloudresourcemanager.googleapis.com
echo "Service Networking API"...
gcloud services enable servicenetworking.googleapis.com
echo "VPC Access API"...
gcloud services enable vpcaccess.googleapis.com

gcloud services enable sqladmin.googleapis.com
