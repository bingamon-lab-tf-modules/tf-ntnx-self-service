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

check "app_patches_resolvable_app_reference" {
  assert {
    condition = alltrue([
      for k, v in var.app_patches :
      v.app_uuid != null || (v.provision != null && contains(keys(var.app_provisions), v.provision))
    ])
    error_message = "Each app_patch must name a resolvable application: either app_uuid, or a provision key present in app_provisions."
  }
}

check "app_custom_actions_resolvable_app_reference" {
  assert {
    condition = alltrue([
      for k, v in var.app_custom_actions :
      v.app_uuid != null || v.app_name != null || (v.provision != null && contains(keys(var.app_provisions), v.provision))
    ])
    error_message = "Each app_custom_action must name a resolvable application: app_uuid, app_name, or a provision key present in app_provisions."
  }
}
