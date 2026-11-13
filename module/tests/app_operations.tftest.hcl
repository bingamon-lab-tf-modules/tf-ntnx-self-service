##################################################
# Unit Tests: Self-Service (Calm) app Day-2 operations (issue 591)
#
# Covers the provision / patch / custom-action resources. All runs are
# mock-only (mock_provider "nutanix") so plans never call the Calm API.
# Assertions check only plan-known values (resource counts, echoed inputs,
# summary totals); computed ids / runlog_uuids are unknown at plan and are not
# asserted. app_provisions/app_patches/app_custom_actions all default to {}.
##################################################

#########################
# Provider
#########################

provider "nutanix" {
  username = "dummy"
  password = "dummy"
  endpoint = "dummy.local"
  port     = 9440
  insecure = true
}

mock_provider "nutanix" {}

#########################
# Tests
#########################

# Test 1: Empty configuration plans zero app-operation resources.
run "app_ops_empty_config" {
  command = plan

  assert {
    condition     = length(nutanix_self_service_app_provision.app_provision) == 0
    error_message = "Expected 0 provision resources for empty config"
  }

  assert {
    condition     = length(nutanix_self_service_app_patch.app_patch) == 0
    error_message = "Expected 0 patch resources for empty config"
  }

  assert {
    condition     = length(nutanix_self_service_app_custom_action.app_custom_action) == 0
    error_message = "Expected 0 custom-action resources for empty config"
  }

  assert {
    condition     = output.self_service_summary.total_provisions == 0 && output.self_service_summary.total_patches == 0 && output.self_service_summary.total_custom_actions == 0
    error_message = "Expected empty app-operation summary counts"
  }
}

# Test 2: One provision + one patch (resolved via provision) + one custom action.
run "app_ops_provision_patch_custom_action" {
  command = plan

  variables {
    app_provisions = {
      web = {
        app_name = "web-stack-prod"
        bp_name  = "web-stack-bp"
        action   = "start"
      }
    }
    app_patches = {
      web_scaleout = {
        provision   = "web"
        config_name = "ScaleOut"
        patch_name  = "ScaleOut"
        vm_config = {
          memory_size_mib = 8192
        }
      }
    }
    app_custom_actions = {
      web_healthcheck = {
        provision   = "web"
        action_name = "HealthCheck"
      }
    }
  }

  assert {
    condition     = length(nutanix_self_service_app_provision.app_provision) == 1
    error_message = "Expected exactly one provision resource"
  }

  assert {
    condition     = length(nutanix_self_service_app_patch.app_patch) == 1
    error_message = "Expected exactly one patch resource"
  }

  assert {
    condition     = length(nutanix_self_service_app_custom_action.app_custom_action) == 1
    error_message = "Expected exactly one custom-action resource"
  }

  assert {
    condition     = nutanix_self_service_app_provision.app_provision["web"].app_name == "web-stack-prod"
    error_message = "Provision app_name did not round-trip"
  }

  assert {
    condition     = nutanix_self_service_app_provision.app_provision["web"].bp_name == "web-stack-bp"
    error_message = "Provision bp_name did not round-trip"
  }

  assert {
    condition     = nutanix_self_service_app_patch.app_patch["web_scaleout"].patch_name == "ScaleOut"
    error_message = "Patch patch_name did not round-trip"
  }

  assert {
    condition     = output.app_patches["web_scaleout"].config_name == "ScaleOut"
    error_message = "Patch config_name did not surface to the output"
  }

  assert {
    condition     = nutanix_self_service_app_custom_action.app_custom_action["web_healthcheck"].action_name == "HealthCheck"
    error_message = "Custom action action_name did not round-trip"
  }

  assert {
    condition     = output.self_service_summary.total_provisions == 1 && output.self_service_summary.total_patches == 1 && output.self_service_summary.total_custom_actions == 1
    error_message = "App-operation summary counts did not match the configuration"
  }
}

# Test 3: A patch with neither provision nor app_uuid must fail validation.
run "app_patch_missing_app_reference" {
  command = plan

  variables {
    app_patches = {
      orphan = {
        config_name = "ScaleOut"
        patch_name  = "ScaleOut"
      }
    }
  }

  expect_failures = [var.app_patches]
}

# Test 4: A provision without a blueprint reference must fail validation.
run "app_provision_missing_blueprint" {
  command = plan

  variables {
    app_provisions = {
      web = {
        app_name = "web-stack-prod"
      }
    }
  }

  expect_failures = [var.app_provisions]
}

# Test 5: A custom action naming two app references must fail validation.
run "app_custom_action_ambiguous_reference" {
  command = plan

  variables {
    app_custom_actions = {
      ambiguous = {
        app_name    = "web-stack-prod"
        app_uuid    = "00000000-0000-0000-0000-000000000000"
        action_name = "HealthCheck"
      }
    }
  }

  expect_failures = [var.app_custom_actions]
}

# Test 6: Provision with runtime_editables (credentials, variables, app_profile)
# and full patch payload (vm_config, categories, disks, nics) against v2.5.1 schema.
run "app_ops_runtime_editables_and_full_patch" {
  command = plan

  variables {
    app_provisions = {
      db = {
        app_name        = "db-stack-prod"
        app_description = "Managed database stack"
        bp_uuid         = "22222222-2222-2222-2222-222222222222"
        soft_delete     = true
        runtime_editables = {
          app_profile = [
            {
              name = "Default"
              uuid = "33333333-3333-3333-3333-333333333333"
            }
          ]
          credential_list = [
            {
              name  = "admin_cred"
              type  = "PASSWORD"
              value = "mock-calm-secret"
            }
          ]
          variable_list = [
            {
              name  = "db_port"
              type  = "INT"
              value = "5432"
            }
          ]
        }
      }
    }
    app_patches = {
      db_resize = {
        app_uuid    = "44444444-4444-4444-4444-444444444444"
        config_name = "Resize"
        patch_name  = "Resize"
        vm_config = {
          memory_size_mib      = 16384
          num_sockets          = 2
          num_vcpus_per_socket = 4
        }
        categories = [
          {
            operation = "add"
            value     = "Environment:Production"
          }
        ]
        disks = [
          {
            operation     = "add"
            disk_size_mib = 102400
          }
        ]
        nics = [
          {
            index       = 0
            operation   = "add"
            subnet_uuid = "55555555-5555-5555-5555-555555555555"
          }
        ]
      }
    }
  }

  assert {
    condition     = nutanix_self_service_app_provision.app_provision["db"].soft_delete == true
    error_message = "Expected provision soft_delete to be true"
  }

  assert {
    condition     = nutanix_self_service_app_provision.app_provision["db"].runtime_editables[0].credential_list[0].name == "admin_cred"
    error_message = "Expected runtime_editables credential_list name to round-trip"
  }

  assert {
    condition     = nutanix_self_service_app_provision.app_provision["db"].runtime_editables[0].variable_list[0].value == "5432"
    error_message = "Expected runtime_editables variable_list value to round-trip"
  }

  assert {
    condition     = nutanix_self_service_app_patch.app_patch["db_resize"].disks[0].disk_size_mib == 102400
    error_message = "Expected patch disk_size_mib to round-trip"
  }

  assert {
    condition     = output.app_provisions["db"].bp_uuid == "22222222-2222-2222-2222-222222222222"
    error_message = "Expected output app_provisions bp_uuid to match input"
  }
}
