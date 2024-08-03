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

variable "domain_name" {
  description = "The domain"
  type        = string
}

variable "dns_zone" {
  description = "The dns zone of the service"
  type        = string
}

variable "google_maps_api_key" {
  description = "The google maps api key used for getting the latitude and longitude of an address"
  type        = string
}

variable "twilio_account_service_id" {
  description = "account service id is like an id for my twilio account"
  type        = string
}

variable "twilio_verify_service_id" {
  description = "The service id for the verify service. (Your twilio account can have multiple verify services and this is the id for one of them)"
  type        = string
}

variable "twilio_auth_token" {
  description = "The service account has an auth token used for twilio requests"
  type        = string
}

