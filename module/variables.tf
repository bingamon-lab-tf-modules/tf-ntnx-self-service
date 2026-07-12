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
