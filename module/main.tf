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

##################################################
# Self-Service App Provisions (issue 591)
##################################################

# Day-2 provisioning of a REAL application from an EXISTING Self-Service
# blueprint. The provider cannot create blueprints/marketplace items or deploy
# Self-Service itself (spec §12). The resource id is the launched application's
# UUID; destroy DELETES the running app (or soft-deletes when soft_delete=true).

resource "nutanix_self_service_app_provision" "app_provision" {
  for_each = var.app_provisions

  app_name        = each.value.app_name
  app_description = each.value.app_description
  bp_name         = each.value.bp_name
  bp_uuid         = each.value.bp_uuid
  action          = each.value.action
  soft_delete     = each.value.soft_delete

  dynamic "runtime_editables" {
    for_each = each.value.runtime_editables != null ? [each.value.runtime_editables] : []
    content {
      dynamic "action_list" {
        for_each = runtime_editables.value.action_list != null ? runtime_editables.value.action_list : []
        content {
          name        = action_list.value.name
          value       = action_list.value.value
          context     = action_list.value.context
          description = action_list.value.description
          type        = action_list.value.type
          uuid        = action_list.value.uuid
        }
      }
      dynamic "app_profile" {
        for_each = runtime_editables.value.app_profile != null ? runtime_editables.value.app_profile : []
        content {
          name        = app_profile.value.name
          value       = app_profile.value.value
          context     = app_profile.value.context
          description = app_profile.value.description
          type        = app_profile.value.type
          uuid        = app_profile.value.uuid
        }
      }
      dynamic "credential_list" {
        for_each = runtime_editables.value.credential_list != null ? runtime_editables.value.credential_list : []
        content {
          name        = credential_list.value.name
          value       = credential_list.value.value
          context     = credential_list.value.context
          description = credential_list.value.description
          type        = credential_list.value.type
          uuid        = credential_list.value.uuid
        }
      }
      dynamic "deployment_list" {
        for_each = runtime_editables.value.deployment_list != null ? runtime_editables.value.deployment_list : []
        content {
          name        = deployment_list.value.name
          value       = deployment_list.value.value
          context     = deployment_list.value.context
          description = deployment_list.value.description
          type        = deployment_list.value.type
          uuid        = deployment_list.value.uuid
        }
      }
      dynamic "package_list" {
        for_each = runtime_editables.value.package_list != null ? runtime_editables.value.package_list : []
        content {
          name        = package_list.value.name
          value       = package_list.value.value
          context     = package_list.value.context
          description = package_list.value.description
          type        = package_list.value.type
          uuid        = package_list.value.uuid
        }
      }
      dynamic "restore_config_list" {
        for_each = runtime_editables.value.restore_config_list != null ? runtime_editables.value.restore_config_list : []
        content {
          name        = restore_config_list.value.name
          value       = restore_config_list.value.value
          context     = restore_config_list.value.context
          description = restore_config_list.value.description
          type        = restore_config_list.value.type
          uuid        = restore_config_list.value.uuid
        }
      }
      dynamic "service_list" {
        for_each = runtime_editables.value.service_list != null ? runtime_editables.value.service_list : []
        content {
          name        = service_list.value.name
          value       = service_list.value.value
          context     = service_list.value.context
          description = service_list.value.description
          type        = service_list.value.type
          uuid        = service_list.value.uuid
        }
      }
      dynamic "snapshot_config_list" {
        for_each = runtime_editables.value.snapshot_config_list != null ? runtime_editables.value.snapshot_config_list : []
        content {
          name        = snapshot_config_list.value.name
          value       = snapshot_config_list.value.value
          context     = snapshot_config_list.value.context
          description = snapshot_config_list.value.description
          type        = snapshot_config_list.value.type
          uuid        = snapshot_config_list.value.uuid
        }
      }
      dynamic "substrate_list" {
        for_each = runtime_editables.value.substrate_list != null ? runtime_editables.value.substrate_list : []
        content {
          name        = substrate_list.value.name
          value       = substrate_list.value.value
          context     = substrate_list.value.context
          description = substrate_list.value.description
          type        = substrate_list.value.type
          uuid        = substrate_list.value.uuid
        }
      }
      dynamic "task_list" {
        for_each = runtime_editables.value.task_list != null ? runtime_editables.value.task_list : []
        content {
          name        = task_list.value.name
          value       = task_list.value.value
          context     = task_list.value.context
          description = task_list.value.description
          type        = task_list.value.type
          uuid        = task_list.value.uuid
        }
      }
      dynamic "variable_list" {
        for_each = runtime_editables.value.variable_list != null ? runtime_editables.value.variable_list : []
        content {
          name        = variable_list.value.name
          value       = variable_list.value.value
          context     = variable_list.value.context
          description = variable_list.value.description
          type        = variable_list.value.type
          uuid        = variable_list.value.uuid
        }
      }
    }
  }
}

##################################################
# Self-Service App Patches (one-shot update-config actions)
##################################################

# Imperative one-shot: create runs the patch once; destroy does NOT undo it.
# The target app UUID resolves against a module-created provision first
# (var.app_patches[*].provision), otherwise a raw app_uuid passthrough.

resource "nutanix_self_service_app_patch" "app_patch" {
  for_each = var.app_patches

  app_uuid = each.value.provision != null ? lookup(local.provision_app_uuids, each.value.provision, null) : each.value.app_uuid

  config_name = each.value.config_name
  patch_name  = each.value.patch_name

  dynamic "vm_config" {
    for_each = each.value.vm_config != null ? [each.value.vm_config] : []
    content {
      memory_size_mib      = vm_config.value.memory_size_mib
      num_sockets          = vm_config.value.num_sockets
      num_vcpus_per_socket = vm_config.value.num_vcpus_per_socket
    }
  }

  dynamic "categories" {
    for_each = each.value.categories != null ? each.value.categories : []
    content {
      operation = categories.value.operation
      value     = categories.value.value
    }
  }

  dynamic "disks" {
    for_each = each.value.disks != null ? each.value.disks : []
    content {
      operation     = disks.value.operation
      disk_size_mib = disks.value.disk_size_mib
    }
  }

  dynamic "nics" {
    for_each = each.value.nics != null ? each.value.nics : []
    content {
      index       = nics.value.index
      operation   = nics.value.operation
      subnet_uuid = nics.value.subnet_uuid
    }
  }
}

##################################################
# Self-Service App Custom Actions (one-shot blueprint day-2 actions)
##################################################

# Imperative one-shot: create runs the custom action once; destroy does NOT
# undo it. The target app resolves against a module-created provision first
# (var.app_custom_actions[*].provision), otherwise a raw app_uuid / app_name.

resource "nutanix_self_service_app_custom_action" "app_custom_action" {
  for_each = var.app_custom_actions

  app_uuid    = each.value.provision != null ? lookup(local.provision_app_uuids, each.value.provision, null) : each.value.app_uuid
  app_name    = each.value.provision != null ? null : each.value.app_name
  action_name = each.value.action_name
}
