provider "google" {
  project = "climbing-app-424905"
  region  = "us-south1"
  zone    = "us-south1-a"
}

# triggers builds that store images in google storage bucket
# then trigger release of that image to the pipeline
resource "google_cloudbuild_trigger" "github-trigger" {
  name        = "github-trigger"
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

  filename = "cloudbuild.yaml"
}

# gives permissions to our github-trigger to execute cloudbuild 
# releases to pipeline
resource "google_project_iam_member" "cloudbuild-releaser-permissions" {
  project = var.project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com"
}

# cloud run service (like a lambda)
resource "google_cloud_run_service" "beta-cloud-run-service" {
  name     = "beta-cloud-run"
  location = var.default_region

  template {
    spec {
      containers {
	image = "gcr.io/cloudrun/hello"

        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
      }
    }
  }
traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_clouddeploy_target" "beta" {
  location          = var.default_region
  name              = "beta"
  deploy_parameters = {}
  description       = "Cloud run deployment target"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
  }

  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${var.project_id}/locations/${var.default_region}"
  }
}


# deployment pipeline
resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location = var.default_region
  name = "climb-service-pipeline"
  description = "Pipeline to deploy climb service changes."

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.beta.target_id
    }
  }
}

resource "google_service_account_iam_binding" "allow-cloudbuild-to-impersonate-compute-environment" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  members            = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}
resource "google_project_iam_binding" "cloud-build-builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  members = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}
resource "google_project_iam_binding" "storage-admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${var.service_account_number}@cloudbuild.gserviceaccount.com",
  ]
}
