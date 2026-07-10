##################################################
# Self-Service Recovery Points
##################################################

# TODO: Self-Service has moved to separate servers.
# The API schema and authentication requirements may need updates.
# These resources exist in the provider but connectivity configuration
# may require additional provider settings.

resource "nutanix_self_service_app_recovery_point" "recovery_point" {
  for_each = var.recovery_points

  app_name            = each.value.app_name
  app_uuid            = each.value.app_uuid
  action_name         = each.value.action_name
  recovery_point_name = each.value.recovery_point_name
}

##################################################
# Self-Service Restores
##################################################

resource "nutanix_self_service_app_restore" "restore" {
  for_each = var.restores

  app_name            = each.value.app_name
  app_uuid            = each.value.app_uuid
  snapshot_uuid       = each.value.snapshot_uuid
  restore_action_name = each.value.restore_action_name
}
