#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/workspaces.sh"
}

teardown() {
  cleanup_test_environment
}

@test "workspaces.sh - switch_workspace function exists" {
  function_exists switch_workspace
}

@test "workspaces.sh - move_to_workspace function exists" {
  function_exists move_to_workspace
}

@test "workspaces.sh - switch_workspace succeeds with valid number" {
  run switch_workspace 1
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - switch_workspace succeeds with number 9" {
  run switch_workspace 9
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - switch_workspace fails with non-numeric input" {
  run switch_workspace "abc"
  [[ "${status}" -eq 1 ]]
}

@test "workspaces.sh - switch_workspace defaults to 1" {
  run switch_workspace
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - move_to_workspace succeeds with valid number" {
  run move_to_workspace 2
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - move_to_workspace fails with non-numeric input" {
  run move_to_workspace "xyz"
  [[ "${status}" -eq 1 ]]
}

@test "workspaces.sh - move_to_workspace defaults to 1" {
  run move_to_workspace
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_WORKSPACES_LOADED}" ]]
  [[ "${_TILING_REVAMPED_WORKSPACES_LOADED}" == "1" ]]
}
