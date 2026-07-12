locals {
  # Recovery points identified by app name vs app UUID
  recovery_points_by_name = { for k, v in var.recovery_points : k => v if v.app_name != null }
  recovery_points_by_uuid = { for k, v in var.recovery_points : k => v if v.app_name == null && v.app_uuid != null }

  # Application name -> UUID, derived from the nutanix_self_service_app lookups
  # (empty when enable_data_lookups is false).
  app_uuid_by_name = {
    for k, app in data.nutanix_self_service_app.app :
    app.app_name => app.app_uuid if app.app_name != null && app.app_name != ""
  }

  # Snapshot/recovery-point entities per lookup label, from the
  # nutanix_self_service_app_snapshots lookups.
  app_snapshot_entities = {
    for k, snap in data.nutanix_self_service_app_snapshots.snapshots :
    k => snap.entities
  }
}
