resource "google_cloud_run_service" "beta-cloud-run" {
  name     = "beta-cloud-run"
  location = var.default_region
  project  = var.project_id

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.beta-postgres-instance.connection_name
      }
    }
  }
  autogenerate_revision_name = true
}

# deploy target (automatically creates the cloud run instance)
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

# creates necessary subdomain that will be used to call the instance
resource "google_dns_record_set" "beta-cname" {
  name         = "beta.${var.domain_name}."
  managed_zone = var.dns_zone
  type         = "CNAME"
  ttl          = 300
  project      = var.project_id

  rrdatas = ["ghs.googlehosted.com."]
}

# creates the mapping such that our subdomain is linked to this instance
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

  depends_on = [google_cloud_run_service.beta-cloud-run]
}

############### SQL ######################
resource "google_sql_database_instance" "beta-postgres-instance" {
  name             = "beta-postgres-instance"
  database_version = "POSTGRES_13"
  region           = var.default_region
  project  = var.project_id

  settings {
    tier = "db-f1-micro"
  }
}

