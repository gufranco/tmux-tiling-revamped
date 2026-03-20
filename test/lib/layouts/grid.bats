#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3'
  export MOCK_TILING_APPLYING="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
}

teardown() {
  cleanup_test_environment
}

@test "grid.sh - apply_layout_grid function exists" {
  function_exists apply_layout_grid
}

@test "grid.sh - apply_layout_grid succeeds with multiple panes" {
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}

@test "grid.sh - apply_layout_grid succeeds with 9 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7\n%8'
  run apply_layout_grid
  [[ "${status}" -eq 0 ]]
}
