##################################################
# Unit Tests: Self-Service (Calm) Day-2 operations
#
# All runs are mock-only (no real Prism Central). Self-Service resources and
# data sources are backed by mock_provider so plans never call the Calm API.
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

#########################
# Mock Data (Nutanix Provider)
#########################

mock_provider "nutanix" {

  # Per-app lookup: app_name is computed, so the mock supplies it.
  mock_data "nutanix_self_service_app" {
    defaults = {
      app_name        = "mock-app"
      app_description = "mock self-service app"
      state           = "running"
      status          = "running"
    }
  }

  # App snapshot listing: entities is a computed list.
  mock_data "nutanix_self_service_app_snapshots" {
    defaults = {
      entities      = []
      total_matches = 0
      kind          = "app_snapshot"
    }
  }
}

#########################
# Tests
#########################

# Test 1: Empty configuration plans zero resources.
run "empty_config" {
  command = plan

  assert {
    condition     = length(nutanix_self_service_app_recovery_point.recovery_point) == 0
    error_message = "Expected 0 recovery point resources for empty config"
  }

  assert {
    condition     = length(nutanix_self_service_app_restore.restore) == 0
    error_message = "Expected 0 restore resources for empty config"
  }

  assert {
    condition     = output.self_service_summary.total_recovery_points == 0 && output.self_service_summary.total_restores == 0
    error_message = "Expected empty summary counts"
  }
}

# Test 2: One recovery point + one restore plan correctly and surface outputs.
run "recovery_point_and_restore" {
  command = plan

  variables {
    recovery_points = {
      web_daily = {
        app_name            = "web-frontend"
        action_name         = "Snapshot"
        recovery_point_name = "web-daily-backup"
      }
    }
    restores = {
      db_restore = {
        app_uuid            = "00000000-0000-0000-0000-000000000000"
        snapshot_uuid       = "11111111-1111-1111-1111-111111111111"
        restore_action_name = "Restore"
      }
    }
  }

  assert {
    condition     = length(nutanix_self_service_app_recovery_point.recovery_point) == 1
    error_message = "Expected exactly one recovery point resource"
  }

  assert {
    condition     = length(nutanix_self_service_app_restore.restore) == 1
    error_message = "Expected exactly one restore resource"
  }

  assert {
    condition     = output.recovery_points["web_daily"].app_name == "web-frontend"
    error_message = "Recovery point app_name did not round-trip to the output"
  }

  assert {
    condition     = output.restores["db_restore"].app_uuid == "00000000-0000-0000-0000-000000000000"
    error_message = "Restore app_uuid did not round-trip to the output"
  }

  assert {
    condition     = output.self_service_summary.total_recovery_points == 1 && output.self_service_summary.total_restores == 1
    error_message = "Summary counts did not match the configured resources"
  }
}

# Test 3: Recovery point with neither app_name nor app_uuid must fail validation.
run "recovery_point_missing_app_reference" {
  command = plan

  variables {
    recovery_points = {
      orphan = {
        action_name         = "Snapshot"
        recovery_point_name = "orphan-backup"
      }
    }
  }

  expect_failures = [var.recovery_points]
}

# Test 4: Recovery point with BOTH app_name and app_uuid must fail validation.
run "recovery_point_both_app_references" {
  command = plan

  variables {
    recovery_points = {
      ambiguous = {
        app_name            = "web-frontend"
        app_uuid            = "00000000-0000-0000-0000-000000000000"
        action_name         = "Snapshot"
        recovery_point_name = "ambiguous-backup"
      }
    }
  }

  expect_failures = [var.recovery_points]
}

# Test 5: Restore with neither app_name nor app_uuid must fail validation.
run "restore_missing_app_reference" {
  command = plan

  variables {
    restores = {
      orphan = {
        snapshot_uuid       = "11111111-1111-1111-1111-111111111111"
        restore_action_name = "Restore"
      }
    }
  }

  expect_failures = [var.restores]
}

# Test 6: Restore with BOTH app_name and app_uuid must fail validation.
run "restore_both_app_references" {
  command = plan

  variables {
    restores = {
      ambiguous = {
        app_name            = "web-frontend"
        app_uuid            = "00000000-0000-0000-0000-000000000000"
        snapshot_uuid       = "11111111-1111-1111-1111-111111111111"
        restore_action_name = "Restore"
      }
    }
  }

  expect_failures = [var.restores]
}

# Test 7: Enabled data lookups drive the app name->uuid derived local/output.
run "data_lookups_enabled" {
  command = plan

  variables {
    enable_data_lookups = true
    app_lookups = {
      primary = {
        app_uuid = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
      }
    }
    app_snapshot_lookups = {
      primary = {
        app_uuid = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
        length   = 20
        offset   = 0
      }
    }
  }

  assert {
    condition     = output.apps["primary"].app_uuid == "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    error_message = "Expected the looked-up app to expose its input UUID"
  }

  assert {
    condition     = output.app_uuid_by_name["mock-app"] == "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    error_message = "Expected app_uuid_by_name to map the mocked app name to its UUID"
  }

  assert {
    condition     = output.self_service_summary.data_lookups_enabled == true
    error_message = "Expected summary to report data lookups as enabled"
  }
}
