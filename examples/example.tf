##################################################
# tf-ntnx-self-service — usage example
#
# Demonstrates Day-2 Self-Service (Calm) application operations against an
# existing application: one recovery point (referenced by app_name) and one
# restore (referenced by app_uuid + snapshot_uuid). The module authenticates
# through the standard provider endpoint/credentials against Prism Central.
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

##################################################
# Module
##################################################

module "self_service" {
  source = "git::https://github.com/bingamon-lab-tf-modules/tf-ntnx-self-service.git//module?ref=v0.1.0"

  # Recovery point for an existing application, referenced by name.
  recovery_points = {
    web_daily = {
      app_name            = "web-frontend"
      action_name         = "Snapshot"
      recovery_point_name = "web-daily-backup"
    }
  }

  # Restore an existing application from a known snapshot, referenced by UUID.
  restores = {
    db_restore = {
      app_uuid            = "00000000-0000-0000-0000-000000000000"
      snapshot_uuid       = "11111111-1111-1111-1111-111111111111"
      restore_action_name = "Restore"
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

output "restores" {
  description = "Restore operations"
  value       = module.self_service.restores
}

output "self_service_summary" {
  description = "Summary of Self-Service resources managed by the module"
  value       = module.self_service.self_service_summary
}
