##################################################
# Self-Service App Recovery Example
# This example demonstrates creating recovery points and restoring applications
##################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.2"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  insecure = true
  port     = 9440
}

##################################################
# Variables
##################################################

variable "nutanix_username" {
  description = "Nutanix Prism Central username"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Nutanix Prism Central endpoint"
  type        = string
}

variable "app_name" {
  description = "Name of the Self-Service application"
  type        = string
}

variable "snapshot_action_name" {
  description = "Name of the snapshot action in the application"
  type        = string
  default     = "Snapshot"
}

##################################################
# Module
##################################################

module "self_service" {
  source = "../../module"

  # Create a recovery point for the application
  recovery_points = {
    daily-backup = {
      app_name            = var.app_name
      action_name         = var.snapshot_action_name
      recovery_point_name = "daily-backup-${formatdate("YYYY-MM-DD", timestamp())}"
    }
  }
}

##################################################
# Outputs
##################################################

output "recovery_points" {
  description = "Created recovery points"
  value       = module.self_service.recovery_points
}
