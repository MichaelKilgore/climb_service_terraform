provider "google" {
  project = "climbing-app-424905"
  region  = "us-south1"
  zone    = "us-south1-a"
}

# triggers builds that store images in google storage bucket
# then trigger release of that image to the pipeline
resource "google_cloudbuild_trigger" "github-trigger" {
  name        = "github-trigger"
  location    = "us-central1"

  github {
    owner = "MichaelKilgore"
    name  = "climb_service"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

# gives permissions to our github-trigger to execute cloudbuild 
# releases to pipeline
resource "google_project_iam_member" "cloudbuild_releaser" {
  project = "climbing-app-424905"
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:221746684991@cloudbuild.gserviceaccount.com"
}

# cloud run service (like a lambda)
resource "google_cloud_run_service" "default" {
  name     = "beta-cloud-run"
  location = "us-south1"

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

resource "google_clouddeploy_target" "primary" {
  location          = "us-south1"
  name              = "beta"
  deploy_parameters = {}
  description       = "Cloud run deployment target"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
  }

  project          = "climbing-app-424905"
  require_approval = false

  run {
    location = "projects/climbing-app-424905/locations/us-south1"
  }
}


# deployment pipeline
resource "google_clouddeploy_delivery_pipeline" "primary" {
  location = "us-south1"
  name = "climb-service-pipeline"
  description = "Pipeline to deploy climb service changes."

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.primary.target_id
    }
  }
}

resource "google_service_account_iam_binding" "allow_cloudbuild_to_impersonate" {
  service_account_id = "projects/climbing-app-424905/serviceAccounts/221746684991-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  members            = [
    "serviceAccount:221746684991@cloudbuild.gserviceaccount.com",
  ]
}
resource "google_project_iam_binding" "cloud_build_builder" {
  project = "climbing-app-424905"
  role    = "roles/cloudbuild.builds.builder"
  members = [
    "serviceAccount:221746684991@cloudbuild.gserviceaccount.com",
  ]
}
resource "google_project_iam_binding" "storage_admin" {
  project = "climbing-app-424905"
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:221746684991@cloudbuild.gserviceaccount.com",
  ]
}
