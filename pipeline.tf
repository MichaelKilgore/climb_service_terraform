resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location = var.default_region
  name = "climb-service-pipeline"
  project = var.project_id
  description = "Pipeline to deploy climb service changes."

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.beta.target_id
      profiles = ["beta"]
    }
  }
}
