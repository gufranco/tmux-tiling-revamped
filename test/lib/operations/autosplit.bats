#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/autosplit.sh"
}

teardown() {
  cleanup_test_environment
}

@test "autosplit.sh - autosplit_pane function exists" {
  function_exists autosplit_pane
}

@test "autosplit.sh - autosplit_pane succeeds with wide pane" {
  export MOCK_PANE_WIDTH="200"
  export MOCK_PANE_HEIGHT="30"
  run autosplit_pane
  [[ "${status}" -eq 0 ]]
}

@test "autosplit.sh - autosplit_pane succeeds with tall pane" {
  export MOCK_PANE_WIDTH="80"
  export MOCK_PANE_HEIGHT="50"
  run autosplit_pane
  [[ "${status}" -eq 0 ]]
}

@test "autosplit.sh - autosplit_pane succeeds with square pane" {
  export MOCK_PANE_WIDTH="100"
  export MOCK_PANE_HEIGHT="50"
  run autosplit_pane
  [[ "${status}" -eq 0 ]]
}
