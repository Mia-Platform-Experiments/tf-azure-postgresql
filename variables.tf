variable "service_name" {
  description = "The name of the service (e.g., payment-service). Used for resource naming."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the existing Resource Group in Azure."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy to."
  type        = string
}

variable "performance_profile" {
  description = "The performance tier selected by the developer (sandbox, development, production). Storage size, backup retention, and high availability are automatically configured based on this profile."
  type        = string

  validation {
    condition     = contains(["sandbox", "development", "production"], var.performance_profile)
    error_message = "Performance profile must be one of: sandbox, development, production."
  }
}

variable "postgres_version" {
  description = "The PostgreSQL version to deploy."
  type        = string
}

variable "database_name" {
  description = "The name of the database to create."
  type        = string
}

variable "administrator_login" {
  description = "The administrator username for the PostgreSQL server."
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL server."
  type        = string
  sensitive   = true
}
