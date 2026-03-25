#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/sync.sh"
}

teardown() {
  cleanup_test_environment
}

@test "sync.sh - sync_panes function exists" {
  function_exists sync_panes
}

@test "sync.sh - sync_panes succeeds" {
  run sync_panes
  [[ "${status}" -eq 0 ]]
}
