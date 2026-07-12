# tf-ntnx-self-service

## Table of Contents

## Overview

A description of the module goes here.

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
| [nutanix_self_service_app_recovery_point.recovery_point](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_recovery_point) | resource |
| [nutanix_self_service_app_restore.restore](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/self_service_app_restore) | resource |
| [nutanix_self_service_app.app](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/self_service_app) | data source |
| [nutanix_self_service_app_snapshots.snapshots](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/self_service_app_snapshots) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_lookups"></a> [app\_lookups](#input\_app\_lookups) | Map of Self-Service applications to look up via the nutanix\_self\_service\_app data source (requires app\_uuid). Only evaluated when enable\_data\_lookups is true. The map key is a caller-chosen label. | <pre>map(object({<br/>    app_uuid = string<br/>  }))</pre> | `{}` | no |
| <a name="input_app_snapshot_lookups"></a> [app\_snapshot\_lookups](#input\_app\_snapshot\_lookups) | Map of Self-Service app snapshot listings to fetch via the nutanix\_self\_service\_app\_snapshots data source. Only evaluated when enable\_data\_lookups is true. Provide exactly one of app\_name or app\_uuid; length/offset control pagination. | <pre>map(object({<br/>    app_name = optional(string)<br/>    app_uuid = optional(string)<br/>    length   = optional(number, 20)<br/>    offset   = optional(number, 0)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_data_lookups"></a> [enable\_data\_lookups](#input\_enable\_data\_lookups) | When true, enable read-only Self-Service data source lookups (app details and app snapshots). These query Prism Central at plan time, so leave false for offline/plan-only or mock\_provider runs. | `bool` | `false` | no |
| <a name="input_recovery_points"></a> [recovery\_points](#input\_recovery\_points) | Map of Self-Service application recovery points to create. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    action_name         = string<br/>    recovery_point_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_restores"></a> [restores](#input\_restores) | Map of Self-Service application restore operations. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    snapshot_uuid       = string<br/>    restore_action_name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_snapshots"></a> [app\_snapshots](#output\_app\_snapshots) | Self-Service application snapshot/recovery-point entities returned by enabled data lookups, keyed by lookup label. |
| <a name="output_app_uuid_by_name"></a> [app\_uuid\_by\_name](#output\_app\_uuid\_by\_name) | Map of Self-Service application name to UUID derived from enabled data lookups. |
| <a name="output_apps"></a> [apps](#output\_apps) | Self-Service application details returned by enabled data lookups, keyed by lookup label. |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs). |
| <a name="output_recovery_points"></a> [recovery\_points](#output\_recovery\_points) | Map of created Self-Service recovery points. |
| <a name="output_restores"></a> [restores](#output\_restores) | Map of Self-Service restore operations. |
| <a name="output_self_service_summary"></a> [self\_service\_summary](#output\_self\_service\_summary) | Summary of Self-Service resources managed by this module. |
<!-- END_TF_DOCS -->
