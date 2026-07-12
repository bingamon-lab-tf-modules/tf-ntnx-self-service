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

  # Application UUID (the resource id) of each module-created app_provision, so
  # app_patches / app_custom_actions can resolve a `provision` reference to a
  # live app UUID (module-created provisions first, raw uuid passthrough otherwise).
  provision_app_uuids = {
    for k, v in nutanix_self_service_app_provision.app_provision : k => v.id
  }
}
