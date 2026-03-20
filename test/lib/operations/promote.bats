#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%1"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/promote.sh"
}

teardown() {
  cleanup_test_environment
}

@test "promote.sh - promote_pane function exists" {
  function_exists promote_pane
}

@test "promote.sh - promote_pane succeeds when non-master focused" {
  export MOCK_PANE_ID="%1"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane succeeds when master focused (demote)" {
  export MOCK_PANE_ID="%0"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  export MOCK_PANE_ID="%0"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane works with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  export MOCK_PANE_ID="%1"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  export MOCK_PANE_ID="%3"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane works with grid layout" {
  export MOCK_TILING_LAYOUT="grid"
  export MOCK_PANE_ID="%2"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}

@test "promote.sh - promote_pane works with no layout set" {
  export MOCK_TILING_LAYOUT=""
  export MOCK_PANE_ID="%1"
  run promote_pane
  [[ "${status}" -eq 0 ]]
}
