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
# beta-cloud-run
