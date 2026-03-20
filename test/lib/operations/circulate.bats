#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/circulate.sh"
}

teardown() {
  cleanup_test_environment
}

@test "circulate.sh - circulate_panes function exists" {
  function_exists circulate_panes
}

@test "circulate.sh - circulate_panes next succeeds" {
  run circulate_panes "next"
  [[ "${status}" -eq 0 ]]
}

@test "circulate.sh - circulate_panes prev succeeds" {
  run circulate_panes "prev"
  [[ "${status}" -eq 0 ]]
}

@test "circulate.sh - circulate_panes exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run circulate_panes
  [[ "${status}" -eq 0 ]]
}
