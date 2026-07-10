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
      v.app_name != null || v.app_uuid != null
    ])
    error_message = "Each recovery point must have either app_name or app_uuid specified."
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
      v.app_name != null || v.app_uuid != null
    ])
    error_message = "Each restore must have either app_name or app_uuid specified."
  }
}
