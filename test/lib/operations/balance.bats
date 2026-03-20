#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_TILING_APPLYING="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/balance.sh"
}

teardown() {
  cleanup_test_environment
}

@test "balance.sh - balance_panes function exists" {
  function_exists balance_panes
}

@test "balance.sh - balance_panes succeeds with grid layout" {
  export MOCK_TILING_LAYOUT="grid"
  run balance_panes
  [[ "${status}" -eq 0 ]]
}

@test "balance.sh - balance_panes succeeds with deck layout" {
  export MOCK_TILING_LAYOUT="deck"
  run balance_panes
  [[ "${status}" -eq 0 ]]
}

@test "balance.sh - balance_panes succeeds with monocle layout" {
  export MOCK_TILING_LAYOUT="monocle"
  run balance_panes
  [[ "${status}" -eq 0 ]]
}

@test "balance.sh - balance_panes succeeds with dwindle layout" {
  export MOCK_TILING_LAYOUT="dwindle"
  run balance_panes
  [[ "${status}" -eq 0 ]]
}

@test "balance.sh - balance_panes succeeds when no layout set" {
  export MOCK_TILING_LAYOUT=""
  run balance_panes
  [[ "${status}" -eq 0 ]]
}
