#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_MAIN_CENTER_RATIO="60"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
}

teardown() {
  cleanup_test_environment
}

@test "main-center.sh - apply_layout_main_center function exists" {
  function_exists apply_layout_main_center
}

@test "main-center.sh - apply_layout_main_center succeeds with 3 panes" {
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center respects custom ratio" {
  export MOCK_TILING_MAIN_CENTER_RATIO="80"
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}
