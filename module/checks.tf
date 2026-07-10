check "recovery_points_have_app_reference" {
  assert {
    condition = alltrue([
      for k, v in var.recovery_points :
      v.app_name != null || v.app_uuid != null
    ])
    error_message = "Recovery points must reference an application by name or UUID."
  }
}

check "restores_have_snapshot" {
  assert {
    condition = alltrue([
      for k, v in var.restores :
      v.snapshot_uuid != null && v.snapshot_uuid != ""
    ])
    error_message = "Restore operations must reference a valid snapshot UUID."
  }
}
