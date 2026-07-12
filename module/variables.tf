variable "recovery_points" {
  description = "Map of Self-Service application recovery points to create."
  type = map(object({
    app_name            = optional(string)
    app_uuid            = optional(string)
    action_name         = string
    recovery_point_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.recovery_points :
      (v.app_name != null) != (v.app_uuid != null)
    ])
    error_message = "Each recovery point must reference an application by exactly one of app_name or app_uuid."
  }
}

variable "restores" {
  description = "Map of Self-Service application restore operations."
  type = map(object({
    app_name            = optional(string)
    app_uuid            = optional(string)
    snapshot_uuid       = string
    restore_action_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.restores :
      (v.app_name != null) != (v.app_uuid != null)
    ])
    error_message = "Each restore must reference an application by exactly one of app_name or app_uuid."
  }
}

variable "enable_data_lookups" {
  description = "When true, enable read-only Self-Service data source lookups (app details and app snapshots). These query Prism Central at plan time, so leave false for offline/plan-only or mock_provider runs."
  type        = bool
  default     = false
}

variable "app_lookups" {
  description = "Map of Self-Service applications to look up via the nutanix_self_service_app data source (requires app_uuid). Only evaluated when enable_data_lookups is true. The map key is a caller-chosen label."
  type = map(object({
    app_uuid = string
  }))
  default = {}
}

variable "app_snapshot_lookups" {
  description = "Map of Self-Service app snapshot listings to fetch via the nutanix_self_service_app_snapshots data source. Only evaluated when enable_data_lookups is true. Provide exactly one of app_name or app_uuid; length/offset control pagination."
  type = map(object({
    app_name = optional(string)
    app_uuid = optional(string)
    length   = optional(number, 20)
    offset   = optional(number, 0)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.app_snapshot_lookups :
      (v.app_name != null) != (v.app_uuid != null)
    ])
    error_message = "Each app_snapshot_lookups entry must reference an application by exactly one of app_name or app_uuid."
  }
}

##################################################
# Self-Service App Day-2 Operations (issue 591)
#
# Provision / patch / custom-action are v1 Calm-API PRODUCT resources: no v2
# exists and the family is EXEMPT from the Q4-CY2026 v2 mandate (spec §5). The
# provider CANNOT deploy Self-Service or create/manage blueprints or
# marketplace items (spec §12, issue 993) — these operate EXISTING applications
# and blueprints only. All three default to {} so nothing is triggered until an
# operator adds an entry to their environment's self-service YAML.
##################################################

variable "app_provisions" {
  description = <<-EOT
    Map of Self-Service (Calm) application provisions launched from EXISTING
    blueprints. The provider CANNOT deploy Self-Service or create/manage
    blueprints or marketplace items (spec §12) — Day-2 app operations only.
    These are v1 Calm-API product resources; no v2 exists and the family is
    exempt from the Q4-CY2026 v2 mandate (spec §5).

    LIFECYCLE / DESTROY SEMANTICS (verified against nutanix/nutanix 2.4.2):
    create launches a REAL application and the resource id becomes the launched
    application UUID. `tofu destroy` DELETES the running application, or
    soft-deletes it when soft_delete = true. Provisions are NOT disposable
    trigger entries like patches/custom actions — removing a map entry tears
    down (or soft-deletes) the live app, and renaming a key destroys the old
    app and provisions a new one.

    Reference the source blueprint by exactly one of bp_name or bp_uuid;
    app_name names the launched application. `action` optionally runs a system
    action (start/stop/restart) after provisioning. `runtime_editables` carries
    the blueprint's runtime-editable values per the 2.4.2 schema.
  EOT
  type = map(object({
    app_name        = string
    app_description = optional(string)
    bp_name         = optional(string)
    bp_uuid         = optional(string)
    action          = optional(string)
    soft_delete     = optional(bool)
    runtime_editables = optional(object({
      action_list          = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      app_profile          = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      credential_list      = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      deployment_list      = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      package_list         = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      restore_config_list  = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      service_list         = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      snapshot_config_list = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      substrate_list       = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      task_list            = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
      variable_list        = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.app_provisions :
      v.app_name != null && v.app_name != ""
    ])
    error_message = "Each app_provision must set a non-empty app_name."
  }

  validation {
    condition = alltrue([
      for k, v in var.app_provisions :
      (v.bp_name != null) != (v.bp_uuid != null)
    ])
    error_message = "Each app_provision must reference its source blueprint by exactly one of bp_name or bp_uuid."
  }
}

variable "app_patches" {
  description = <<-EOT
    Map of one-shot Self-Service (Calm) patch (update-config) actions run
    against provisioned applications. IMPERATIVE ONE-SHOT: creating an entry
    RUNS the patch once; there is no continuous reconciliation. Re-running means
    adding a NEW map key (entries are append-only trigger history) — a destroy
    does NOT undo the patch, and renaming a key re-executes it. Results
    (runlog_uuid) are stored in state.

    v1 Calm-API product resource; no v2 exists, exempt from the Q4-CY2026 v2
    mandate (spec §5). Day-2 ops against EXISTING blueprints only — the provider
    cannot deploy Self-Service or manage blueprints/marketplace (spec §12).

    Reference the target application by exactly one of `provision` (a key of
    var.app_provisions, resolved to that module-created app's UUID) or `app_uuid`
    (a raw passthrough UUID). config_name and patch_name identify the patch
    action (config_name must equal patch_name for single-VM blueprints). The
    optional vm_config/categories/disks/nics blocks carry the patch payload.
  EOT
  type = map(object({
    provision   = optional(string)
    app_uuid    = optional(string)
    config_name = string
    patch_name  = string
    vm_config = optional(object({
      memory_size_mib      = optional(number)
      num_sockets          = optional(number)
      num_vcpus_per_socket = optional(number)
    }))
    categories = optional(list(object({
      operation = string
      value     = optional(string)
    })))
    disks = optional(list(object({
      operation     = string
      disk_size_mib = optional(number)
    })))
    nics = optional(list(object({
      index       = optional(number)
      operation   = optional(string)
      subnet_uuid = optional(string)
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.app_patches :
      length([for r in [v.provision, v.app_uuid] : r if r != null]) == 1
    ])
    error_message = "Each app_patch must reference its target application by exactly one of provision (an app_provisions key) or app_uuid."
  }
}

variable "app_custom_actions" {
  description = <<-EOT
    Map of one-shot Self-Service (Calm) blueprint-defined custom day-2 actions
    run against provisioned applications. IMPERATIVE ONE-SHOT: creating an entry
    RUNS the action once; there is no continuous reconciliation. Re-running means
    adding a NEW map key (entries are append-only trigger history) — a destroy
    does NOT undo the action, and renaming a key re-executes it. Results
    (runlog_uuid) are stored in state.

    v1 Calm-API product resource; no v2 exists, exempt from the Q4-CY2026 v2
    mandate (spec §5). Day-2 ops against EXISTING blueprints only — the provider
    cannot deploy Self-Service or manage blueprints/marketplace (spec §12).

    Reference the target application by exactly one of `provision` (a key of
    var.app_provisions, resolved to that module-created app's UUID), `app_uuid`,
    or `app_name`. action_name is the blueprint-defined action to run.
  EOT
  type = map(object({
    provision   = optional(string)
    app_name    = optional(string)
    app_uuid    = optional(string)
    action_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.app_custom_actions :
      length([for r in [v.provision, v.app_name, v.app_uuid] : r if r != null]) == 1
    ])
    error_message = "Each app_custom_action must reference its target application by exactly one of provision (an app_provisions key), app_name, or app_uuid."
  }
}
