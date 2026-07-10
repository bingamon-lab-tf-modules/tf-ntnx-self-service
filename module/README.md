# tf-ntnx-self-service

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_recovery_points"></a> [recovery\_points](#input\_recovery\_points) | Map of Self-Service application recovery points to create. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    action_name         = string<br/>    recovery_point_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_restores"></a> [restores](#input\_restores) | Map of Self-Service application restore operations. | <pre>map(object({<br/>    app_name            = optional(string)<br/>    app_uuid            = optional(string)<br/>    snapshot_uuid       = string<br/>    restore_action_name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_recovery_points"></a> [recovery\_points](#output\_recovery\_points) | Map of created Self-Service recovery points. |
| <a name="output_restores"></a> [restores](#output\_restores) | Map of Self-Service restore operations. |
| <a name="output_self_service_summary"></a> [self\_service\_summary](#output\_self\_service\_summary) | Summary of Self-Service resources managed by this module. |
<!-- END_TF_DOCS -->
