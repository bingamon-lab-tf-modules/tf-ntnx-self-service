##################################################
# Data Sources for Self-Service
##################################################

# Self-Service data lookups authenticate through the standard provider
# endpoint/credentials against Prism Central (see main.tf). They are gated by
# var.enable_data_lookups so the module stays plan-safe offline and under
# mock_provider when no lookups are requested.

# Per-app details (blueprint, profile, state, VMs) keyed by a caller label.
data "nutanix_self_service_app" "app" {
  for_each = var.enable_data_lookups ? var.app_lookups : {}

  app_uuid = each.value.app_uuid
}

# Paginated list of an application's recovery points / snapshots.
data "nutanix_self_service_app_snapshots" "snapshots" {
  for_each = var.enable_data_lookups ? var.app_snapshot_lookups : {}

  app_name = each.value.app_name
  app_uuid = each.value.app_uuid
  length   = each.value.length
  offset   = each.value.offset
}
