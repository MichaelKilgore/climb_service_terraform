gcloud config set project ${PROJECT_ID}

echo "Enabling GCP APIs, please wait, this may take several minutes..."
echo "Storage API"...
gcloud services enable storage.googleapis.com
echo "Compute API"...
gcloud services enable compute.googleapis.com
echo "Artifact Registry API"...
gcloud services enable artifactregistry.googleapis.com
