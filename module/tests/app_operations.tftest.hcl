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
