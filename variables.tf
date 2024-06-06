variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "default_region" {
  description = "The preferred region to deploy resources"
  type        = string
}

variable "default_zone" {
  description = "The preferred zone to deploy resources"
  type        = string
}

variable "service_account_number" {
  description = "The service account number"
  type        = string
}
