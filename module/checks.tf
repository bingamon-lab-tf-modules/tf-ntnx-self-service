check "recovery_points_single_app_reference" {
  assert {
    condition = alltrue([
      for k, v in var.recovery_points :
      (v.app_name != null) != (v.app_uuid != null)
    ])
    error_message = "Each recovery point must reference an application by exactly one of app_name or app_uuid."
  }
}

check "restores_single_app_reference" {
  assert {
    condition = alltrue([
      for k, v in var.restores :
      (v.app_name != null) != (v.app_uuid != null)
    ])
    error_message = "Each restore must reference an application by exactly one of app_name or app_uuid."
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
