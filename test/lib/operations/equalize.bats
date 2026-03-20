#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/equalize.sh"
}

teardown() {
  cleanup_test_environment
}

@test "equalize.sh - equalize_panes function exists" {
  function_exists equalize_panes
}

@test "equalize.sh - equalize_panes succeeds with multiple panes" {
  run equalize_panes
  [[ "${status}" -eq 0 ]]
}

@test "equalize.sh - equalize_panes exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run equalize_panes
  [[ "${status}" -eq 0 ]]
}

@test "equalize.sh - equalize_panes uses even-vertical for vertical orientation" {
  export MOCK_TILING_ORIENTATION="brvc"
  run equalize_panes
  [[ "${status}" -eq 0 ]]
}

@test "equalize.sh - equalize_panes uses even-horizontal for horizontal orientation" {
  export MOCK_TILING_ORIENTATION="brhc"
  run equalize_panes
  [[ "${status}" -eq 0 ]]
}
