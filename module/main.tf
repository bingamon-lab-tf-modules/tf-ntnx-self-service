##################################################
# Self-Service Recovery Points
##################################################

# Connection / authentication (verified against nutanix/nutanix 2.4.2):
# Self-Service (Calm) resources use the Calm v3 product API and authenticate
# through the STANDARD provider `endpoint`/credentials against Prism Central.
# There is NO separate self-service endpoint or extra provider argument, and
# the provider CANNOT deploy Self-Service itself — only Day-2 application
# operations (recovery-point, restore, provision/patch/custom-action) are
# supported. Blueprints and applications must already exist in Self-Service;
# there is no blueprint-authoring resource. Self-Service is exempt from the
# Q4-CY2026 v2 deprecation because no v2 replacement exists.

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
