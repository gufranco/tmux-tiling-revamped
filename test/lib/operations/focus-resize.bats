#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_FOCUS_RATIO="62"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/focus-resize.sh"
}

teardown() {
  cleanup_test_environment
}

@test "focus-resize.sh - focus_resize_pane function exists" {
  function_exists focus_resize_pane
}

@test "focus-resize.sh - focus_resize_pane succeeds with multiple panes" {
  run focus_resize_pane
  [[ "${status}" -eq 0 ]]
}

@test "focus-resize.sh - focus_resize_pane exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run focus_resize_pane
  [[ "${status}" -eq 0 ]]
}

@test "focus-resize.sh - focus_resize_pane respects custom ratio" {
  export MOCK_TILING_FOCUS_RATIO="75"
  run focus_resize_pane
  [[ "${status}" -eq 0 ]]
}

@test "focus-resize.sh - focus_resize_pane clamps ratio to min" {
  export MOCK_TILING_FOCUS_RATIO="5"
  run focus_resize_pane
  [[ "${status}" -eq 0 ]]
}

@test "focus-resize.sh - focus_resize_pane clamps ratio to max" {
  export MOCK_TILING_FOCUS_RATIO="95"
  run focus_resize_pane
  [[ "${status}" -eq 0 ]]
}
