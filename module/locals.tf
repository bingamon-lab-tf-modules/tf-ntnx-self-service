locals {
  # Recovery points identified by app name vs app UUID
  recovery_points_by_name = { for k, v in var.recovery_points : k => v if v.app_name != null }
  recovery_points_by_uuid = { for k, v in var.recovery_points : k => v if v.app_name == null && v.app_uuid != null }
}
