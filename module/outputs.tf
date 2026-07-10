output "recovery_points" {
  description = "Map of created Self-Service recovery points."
  value = {
    for k, v in nutanix_self_service_app_recovery_point.recovery_point : k => {
      app_name            = v.app_name
      app_uuid            = v.app_uuid
      action_name         = v.action_name
      recovery_point_name = v.recovery_point_name
    }
  }
}

output "restores" {
  description = "Map of Self-Service restore operations."
  value = {
    for k, v in nutanix_self_service_app_restore.restore : k => {
      app_name            = v.app_name
      app_uuid            = v.app_uuid
      restore_action_name = v.restore_action_name
      state               = v.state
    }
  }
}

output "self_service_summary" {
  description = "Summary of Self-Service resources managed by this module."
  value = {
    status                = "SCHEMA_PENDING"
    total_recovery_points = length(var.recovery_points)
    total_restores        = length(var.restores)
  }
}
