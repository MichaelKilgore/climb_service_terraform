resource "google_cloudbuild_trigger" "github-trigger" {
  name        = "github-trigger"
  project  = var.project_id
  # triggers aren't allowed in our prefered us-south1 region for some reason
  location    = "us-central1"

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
  }

  # had to delete the trigger manually and then add this
  # service account for it to work.
  service_account = "projects/-/serviceAccounts/${google_service_account.github-trigger.email}"
  filename = "cloudbuild.yaml"
}

