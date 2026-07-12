# tf-ntnx-self-service

## Table of Contents

## Overview

Day-2 operations for Nutanix Self-Service (Calm / NCM) applications: recovery
points, restores, and — as of issue 591 — application provisions, patches, and
custom actions. Every operation runs through the standard provider
`endpoint`/credentials against Prism Central; there is no separate Self-Service
endpoint or extra provider argument.

## Capability Boundary

This module performs Day-2 operations against a **manually-deployed**
Self-Service instance and **existing** blueprints only. The `nutanix` provider
(>= 2.4.2) **cannot**:

- deploy or configure Self-Service / Calm itself, and
- create or manage blueprints or marketplace items.

There is no blueprint-authoring or marketplace resource in the provider, so
those steps stay manual (spec §12, issue 993 conclusion). All five
Self-Service app-operation resources are **v1 Calm-API product resources**: no
v2 replacement exists, and the family is **exempt from the Q4-CY2026 v2
mandate** (reviewed each provider release, spec §5).

## Action-Resource Lifecycle Caveats

The provision / patch / custom-action resources (`app_provisions`,
`app_patches`, `app_custom_actions`) are **imperative**, not declaratively
reconciled. Read these before wiring them:

1. **Patches and custom actions are one-shot.** Creating an `app_patch` or
   `app_custom_action` entry RUNS the action exactly once; there is no
   continuous reconciliation. To run again, add a NEW map key — entries are an
   append-only trigger history, and a destroy does NOT undo the action.
2. **Provisions launch a real app; destroy tears it down.** Creating an
   `app_provision` launches a REAL application, and the resource id becomes the
   launched application's UUID. `tofu destroy` DELETES the running application,
   or soft-deletes it when `soft_delete = true`. Provisions are NOT disposable
   trigger entries — removing an entry removes (or soft-deletes) the live app.
3. **Never default these maps to non-empty values.** All three variables
   default to `{}`. Operators trigger an operation by adding an entry to their
   environment's self-service YAML; keep trigger entries out of always-applied
   `config.yaml` defaults.
4. **Results are stored in state; renaming a key re-executes.** A patch/action
   `runlog_uuid` and a provision's app UUID are recorded in state, so renaming a
   map key is a destroy+create that re-executes the action (or re-provisions the
   app).

Patches and custom actions reference their target application against
module-created provisions first (`provision` = an `app_provisions` key,
resolved to that app's UUID), falling back to a raw `app_uuid` (and, for custom
actions, `app_name`).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [nutanix_self_service_app_custom_action.app_custom_action](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_custom_action) | resource |
| [nutanix_self_service_app_patch.app_patch](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_patch) | resource |
| [nutanix_self_service_app_provision.app_provision](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_provision) | resource |
| [nutanix_self_service_app_recovery_point.recovery_point](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_recovery_point) | resource |
| [nutanix_self_service_app_restore.restore](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_restore) | resource |
| [nutanix_self_service_app.app](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/self_service_app) | data source |
| [nutanix_self_service_app_snapshots.snapshots](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/self_service_app_snapshots) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_custom_actions"></a> [app\_custom\_actions](#input\_app\_custom\_actions) | Map of one-shot Self-Service (Calm) blueprint-defined custom day-2 actions<br/>run against provisioned applications. IMPERATIVE ONE-SHOT: creating an entry<br/>RUNS the action once; there is no continuous reconciliation. Re-running means<br/>adding a NEW map key (entries are append-only trigger history) — a destroy<br/>does NOT undo the action, and renaming a key re-executes it. Results<br/>(runlog\_uuid) are stored in state.<br/><br/>v1 Calm-API product resource; no v2 exists, exempt from the Q4-CY2026 v2<br/>mandate (spec §5). Day-2 ops against EXISTING blueprints only — the provider<br/>cannot deploy Self-Service or manage blueprints/marketplace (spec §12).<br/><br/>Reference the target application by exactly one of `provision` (a key of<br/>var.app\_provisions, resolved to that module-created app's UUID), `app_uuid`,<br/>or `app_name`. action\_name is the blueprint-defined action to run. | <pre>map(object({<br/>    provision   = optional(string)<br/>    app_name    = optional(string)<br/>    app_uuid    = optional(string)<br/>    action_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_app_lookups"></a> [app\_lookups](#input\_app\_lookups) | Map of Self-Service applications to look up via the nutanix\_self\_service\_app data source (requires app\_uuid). Only evaluated when enable\_data\_lookups is true. The map key is a caller-chosen label. | <pre>map(object({<br/>    app_uuid = string<br/>  }))</pre> | `{}` | no |
| <a name="input_app_patches"></a> [app\_patches](#input\_app\_patches) | Map of one-shot Self-Service (Calm) patch (update-config) actions run<br/>against provisioned applications. IMPERATIVE ONE-SHOT: creating an entry<br/>RUNS the patch once; there is no continuous reconciliation. Re-running means<br/>adding a NEW map key (entries are append-only trigger history) — a destroy<br/>does NOT undo the patch, and renaming a key re-executes it. Results<br/>(runlog\_uuid) are stored in state.<br/><br/>v1 Calm-API product resource; no v2 exists, exempt from the Q4-CY2026 v2<br/>mandate (spec §5). Day-2 ops against EXISTING blueprints only — the provider<br/>cannot deploy Self-Service or manage blueprints/marketplace (spec §12).<br/><br/>Reference the target application by exactly one of `provision` (a key of<br/>var.app\_provisions, resolved to that module-created app's UUID) or `app_uuid`<br/>(a raw passthrough UUID). config\_name and patch\_name identify the patch<br/>action (config\_name must equal patch\_name for single-VM blueprints). The<br/>optional vm\_config/categories/disks/nics blocks carry the patch payload. | <pre>map(object({<br/>    provision   = optional(string)<br/>    app_uuid    = optional(string)<br/>    config_name = string<br/>    patch_name  = string<br/>    vm_config = optional(object({<br/>      memory_size_mib      = optional(number)<br/>      num_sockets          = optional(number)<br/>      num_vcpus_per_socket = optional(number)<br/>    }))<br/>    categories = optional(list(object({<br/>      operation = string<br/>      value     = optional(string)<br/>    })))<br/>    disks = optional(list(object({<br/>      operation     = string<br/>      disk_size_mib = optional(number)<br/>    })))<br/>    nics = optional(list(object({<br/>      index       = optional(number)<br/>      operation   = optional(string)<br/>      subnet_uuid = optional(string)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_app_provisions"></a> [app\_provisions](#input\_app\_provisions) | Map of Self-Service (Calm) application provisions launched from EXISTING<br/>blueprints. The provider CANNOT deploy Self-Service or create/manage<br/>blueprints or marketplace items (spec §12) — Day-2 app operations only.<br/>These are v1 Calm-API product resources; no v2 exists and the family is<br/>exempt from the Q4-CY2026 v2 mandate (spec §5).<br/><br/>LIFECYCLE / DESTROY SEMANTICS (verified against nutanix/nutanix 2.4.2):<br/>create launches a REAL application and the resource id becomes the launched<br/>application UUID. `tofu destroy` DELETES the running application, or<br/>soft-deletes it when soft\_delete = true. Provisions are NOT disposable<br/>trigger entries like patches/custom actions — removing a map entry tears<br/>down (or soft-deletes) the live app, and renaming a key destroys the old<br/>app and provisions a new one.<br/><br/>Reference the source blueprint by exactly one of bp\_name or bp\_uuid;<br/>app\_name names the launched application. `action` optionally runs a system<br/>action (start/stop/restart) after provisioning. `runtime_editables` carries<br/>the blueprint's runtime-editable values per the 2.4.2 schema. | <pre>map(object({<br/>    app_name        = string<br/>    app_description = optional(string)<br/>    bp_name         = optional(string)<br/>    bp_uuid         = optional(string)<br/>    action          = optional(string)<br/>    soft_delete     = optional(bool)<br/>    runtime_editables = optional(object({<br/>      action_list          = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      app_profile          = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      credential_list      = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      deployment_list      = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      package_list         = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      restore_config_list  = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      service_list         = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      snapshot_config_list = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      substrate_list       = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      task_list            = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>      variable_list        = optional(list(object({ name = optional(string), value = optional(string), context = optional(string), description = optional(string), type = optional(string), uuid = optional(string) })))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_app_snapshot_lookups"></a> [app\_snapshot\_lookups](#input\_app\_snapshot\_lookups) | Map of Self-Service app snapshot listings to fetch via the nutanix\_self\_service\_app\_snapshots data source. Only evaluated when enable\_data\_lookups is true. Provide exactly one of app\_name or app\_uuid; length/offset control pagination. | <pre>map(object({<br/>    app_name = optional(string)<br/>    app_uuid = optional(string)<br/>    length   = optional(number, 20)<br/>    offset   = optional(number, 0)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_data_lookups"></a> [enable\_data\_lookups](#input\_enable\_data\_lookups) | When true, enable read-only Self-Service data source lookups (app details and app snapshots). These query Prism Central at plan time, so leave false for offline/plan-only or mock\_provider runs. | `bool` | `false` | no |
| <a name="input_recovery_points"></a> [recovery\_points](#input\_recovery\_points) | Map of Self-Service application recovery points to create. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    action_name         = string<br/>    recovery_point_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_restores"></a> [restores](#input\_restores) | Map of Self-Service application restore operations. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    snapshot_uuid       = string<br/>    restore_action_name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_custom_actions"></a> [app\_custom\_actions](#output\_app\_custom\_actions) | Map of Self-Service one-shot custom actions run by this module, keyed by action label. |
| <a name="output_app_patches"></a> [app\_patches](#output\_app\_patches) | Map of Self-Service one-shot patch actions run by this module, keyed by patch label. |
| <a name="output_app_provision_ids"></a> [app\_provision\_ids](#output\_app\_provision\_ids) | Map of Self-Service app provision label to the launched application UUID (the resource id). |
| <a name="output_app_provisions"></a> [app\_provisions](#output\_app\_provisions) | Map of Self-Service application provisions created by this module, keyed by provision label (app\_uuid is the launched application UUID). |
| <a name="output_app_snapshots"></a> [app\_snapshots](#output\_app\_snapshots) | Self-Service application snapshot/recovery-point entities returned by enabled data lookups, keyed by lookup label. |
| <a name="output_app_uuid_by_name"></a> [app\_uuid\_by\_name](#output\_app\_uuid\_by\_name) | Map of Self-Service application name to UUID derived from enabled data lookups. |
| <a name="output_apps"></a> [apps](#output\_apps) | Self-Service application details returned by enabled data lookups, keyed by lookup label. |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs). |
| <a name="output_recovery_points"></a> [recovery\_points](#output\_recovery\_points) | Map of created Self-Service recovery points. |
| <a name="output_restores"></a> [restores](#output\_restores) | Map of Self-Service restore operations. |
| <a name="output_self_service_summary"></a> [self\_service\_summary](#output\_self\_service\_summary) | Summary of Self-Service resources managed by this module. |
<!-- END_TF_DOCS -->
