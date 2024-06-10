# cloud run service (like a lambda)
resource "google_cloud_run_service" "beta-cloud-run-service" {
  name     = "beta-cloud-run"
  location = var.default_region

  template {
    spec {
      containers {
        image = "gcr.io/climbing-app-424905/my-rust-app"

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
    location = "projects/${var.project_id}/locations/${var.default_region}/services/beta-cloud-run"
  }
}
