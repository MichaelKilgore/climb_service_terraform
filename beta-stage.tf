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

resource "google_dns_record_set" "beta-cname" {
  name         = "beta.${var.domain_name}."
  managed_zone = var.dns_zone
  type         = "CNAME"
  ttl          = 300
  project      = var.project_id

  rrdatas = ["ghs.googlehosted.com."]
}

resource "google_cloud_run_domain_mapping" "beta-domain-mapping" {
  location = "us-central1"
  name     = "beta.${var.domain_name}"
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = "beta-cloud-run"
  }
}
