resource "google_service_account" "github-trigger" {
  account_id   = "github-trigger"
  display_name = "Service account used by github trigger."
}

# right now these are just the default permissions that trigger would be given
# without a service account attached. I should trim this down to only permissions needed
# at some point.
# https://cloud.google.com/build/docs/cloud-build-service-account 
resource "google_project_iam_custom_role" "github-trigger-permissions-role" {
  role_id     = "githubTriggerPermissionsRoleId"
  title       = "Gives permissions Needed to github trigger account."
  description = "Gives permissions Needed to github trigger account."
  permissions = [
    "cloudbuild.builds.create",
    "cloudbuild.builds.update",
    "cloudbuild.builds.list",
    "cloudbuild.builds.get",
    "cloudbuild.workerpools.use",
    "logging.logEntries.create",
    "logging.logEntries.list",
    "logging.views.access",
    "pubsub.topics.create",
    "pubsub.topics.publish",
    "remotebuildexecution.blobs.get",
    "resourcemanager.projects.get",
    "source.repos.get",
    "source.repos.list",
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.list",
    "storage.objects.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "artifactregistry.repositories.uploadArtifacts",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.aptartifacts.create",
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
    "artifactregistry.kfpartifacts.create",
    "artifactregistry.locations.get",
    "artifactregistry.locations.list",
    "artifactregistry.mavenartifacts.get",
    "artifactregistry.mavenartifacts.list",
    "artifactregistry.npmpackages.get",
    "artifactregistry.npmpackages.list",
    "artifactregistry.projectsettings.get",
    "artifactregistry.pythonpackages.get",
    "artifactregistry.pythonpackages.list",
    "artifactregistry.yumartifacts.create",
    "artifactregistry.repositories.createOnPush",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.listEffectiveTags",
    "artifactregistry.repositories.listTagBindings",
    "artifactregistry.tags.create",
    "artifactregistry.tags.get",
    "artifactregistry.tags.list",
    "artifactregistry.tags.update",
    "artifactregistry.versions.list",
    "artifactregistry.versions.get",
    "containeranalysis.occurrences.create",
    "containeranalysis.occurrences.delete",
    "containeranalysis.occurrences.get",
    "containeranalysis.occurrences.list",
    "containeranalysis.occurrences.update"
  ]
  project = var.project_id
}

resource "google_project_iam_member" "github-trigger-permissions-role-assignment" {
  project = var.project_id
  role    = google_project_iam_custom_role.github-trigger-permissions-role.name
  member  = "serviceAccount:${google_service_account.github-trigger.email}"
}

# gives permissions to our github-trigger to execute cloudbuild
# releases to pipeline
resource "google_project_iam_member" "cloudbuild-releaser-permissions" {
  project = var.project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.github-trigger.email}"
}

# I can't remember what this role is for
resource "google_service_account_iam_binding" "allow-cloudbuild-to-impersonate-compute-environment" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  members            = [
    "serviceAccount:${google_service_account.github-trigger.email}",
  ]
}

# gives permissions to cloudbuild to execute builds?
resource "google_project_iam_binding" "cloud-build-builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  members = [
    "serviceAccount:${google_service_account.github-trigger.email}",
  ]
}
resource "google_project_iam_binding" "cloud-build-viewer" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.viewer"
  members = [
    "serviceAccount:${google_service_account.github-trigger.email}",
  ]
}

# gives administrative access to google cloud storage
resource "google_project_iam_binding" "storage-admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.github-trigger.email}",
  ]
}

