resource "google_cloudbuild_trigger" "github-trigger" {
  name        = "github-trigger"
  # triggers aren't allowed in our prefered us-south1 region for some reason
  location    = "us-central1"
  project     = var.project_id
  service_account = "projects/climbing-app-426701/serviceAccounts/trigger-service-account@climbing-app-426701.iam.gserviceaccount.com"

  github {
    owner = "MichaelKilgore"
    name  = "climb_service"
    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _PROJECT_ID = var.project_id
    _DEFAULT_REGION = var.default_region
    _PIPELINE_NAME = "climb-service-pipeline"
    _GOOGLE_MAPS_API_KEY = var.google_maps_api_key
    _TWILIO_ACCOUNT_SERVICE_ID = var.twilio_account_service_id
    _TWILIO_VERIFY_SERVICE_ID = var.twilio_verify_service_id
    _TWILIO_AUTH_TOKEN = var.twilio_auth_token
  }

  filename = "cloudbuild.yaml"
}

# gives permissions to our github-trigger to execute cloudbuild
# releases to pipeline
resource "google_project_iam_member" "cloudbuild-releaser-permissions" {
  project = var.project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com"
}

# I can't remember what this role is for
resource "google_service_account_iam_binding" "allow-cloudbuild-to-impersonate-compute-environment" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  members            = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}

# gives permissions to cloudbuild to execute builds?
resource "google_project_iam_binding" "cloud-build-builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  members = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}

# gives administrative access to google cloud storage
resource "google_project_iam_binding" "storage-admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}
