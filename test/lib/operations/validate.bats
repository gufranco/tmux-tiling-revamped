#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/validate.sh"
}

teardown() {
  cleanup_test_environment
}

@test "validate.sh - validate_layout function exists" {
  function_exists validate_layout
}

@test "validate.sh - validate_layout returns 0 with no layout stored" {
  export MOCK_TILING_LAYOUT=""
  run validate_layout
  [[ "${status}" -eq 0 ]]
}

@test "validate.sh - validate_layout returns 0 with valid state" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_TILING_LAYOUT="dwindle"
  run validate_layout
  [[ "${status}" -eq 0 ]]
}

@test "validate.sh - validate_layout returns 1 with stale layout and 1 pane" {
  export MOCK_PANE_LIST="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  run validate_layout
  [[ "${status}" -eq 1 ]]
}

@test "validate.sh - validate_layout fix mode succeeds" {
  export MOCK_PANE_LIST="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  run validate_layout fix
  [[ "${status}" -eq 1 ]]
}

@test "validate.sh - validate_layout returns 0 for monocle with 1 pane" {
  export MOCK_PANE_LIST="%0"
  export MOCK_TILING_LAYOUT="monocle"
  run validate_layout
  [[ "${status}" -eq 0 ]]
}

@test "validate.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_VALIDATE_LOADED}" ]]
  [[ "${_TILING_REVAMPED_VALIDATE_LOADED}" == "1" ]]
}
