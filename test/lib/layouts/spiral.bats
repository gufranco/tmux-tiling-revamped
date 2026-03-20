#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_ORIENTATION="brvs"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
}

teardown() {
  cleanup_test_environment
}

@test "spiral.sh - apply_layout_spiral function exists" {
  function_exists apply_layout_spiral
}

@test "spiral.sh - apply_layout_spiral succeeds with multiple panes" {
  run apply_layout_spiral "brvs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral forces spiral trajectory" {
  # Even when 'c' is in the flags, spiral layout should use spiral trajectory
  run apply_layout_spiral "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral with horizontal orientation" {
  run apply_layout_spiral "brhs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral with top-left corner" {
  run apply_layout_spiral "tlvs"
  [[ "${status}" -eq 0 ]]
}
