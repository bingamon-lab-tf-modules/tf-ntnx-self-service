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
    status                  = "active"
    data_lookups_enabled    = var.enable_data_lookups
    total_recovery_points   = length(var.recovery_points)
    total_restores          = length(var.restores)
    total_app_lookups       = var.enable_data_lookups ? length(var.app_lookups) : 0
    recovery_points_by_name = length(local.recovery_points_by_name)
    recovery_points_by_uuid = length(local.recovery_points_by_uuid)
  }
}

output "apps" {
  description = "Self-Service application details returned by enabled data lookups, keyed by lookup label."
  value = {
    for k, app in data.nutanix_self_service_app.app : k => {
      app_name = app.app_name
      app_uuid = app.app_uuid
      state    = app.state
    }
  }
}

output "app_uuid_by_name" {
  description = "Map of Self-Service application name to UUID derived from enabled data lookups."
  value       = local.app_uuid_by_name
}

output "app_snapshots" {
  description = "Self-Service application snapshot/recovery-point entities returned by enabled data lookups, keyed by lookup label."
  value       = local.app_snapshot_entities
}

##################################################
# Aggregate Output (spec §7.6 contract)
##################################################

output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  value = {
    recovery_points = {
      for k, v in nutanix_self_service_app_recovery_point.recovery_point : k => {
        app_name            = v.app_name
        app_uuid            = v.app_uuid
        action_name         = v.action_name
        recovery_point_name = v.recovery_point_name
      }
    }
    restores = {
      for k, v in nutanix_self_service_app_restore.restore : k => {
        app_name            = v.app_name
        app_uuid            = v.app_uuid
        restore_action_name = v.restore_action_name
        state               = v.state
      }
    }
    self_service_summary = {
      status                  = "active"
      data_lookups_enabled    = var.enable_data_lookups
      total_recovery_points   = length(var.recovery_points)
      total_restores          = length(var.restores)
      total_app_lookups       = var.enable_data_lookups ? length(var.app_lookups) : 0
      recovery_points_by_name = length(local.recovery_points_by_name)
      recovery_points_by_uuid = length(local.recovery_points_by_uuid)
    }
    apps = {
      for k, app in data.nutanix_self_service_app.app : k => {
        app_name = app.app_name
        app_uuid = app.app_uuid
        state    = app.state
      }
    }
    app_uuid_by_name = local.app_uuid_by_name
    app_snapshots    = local.app_snapshot_entities
  }
}
