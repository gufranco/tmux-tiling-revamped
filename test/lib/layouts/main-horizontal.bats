#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_TILING_APPLYING="0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_MASTER_RATIO="60"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
}

teardown() {
  cleanup_test_environment
}

@test "main-horizontal.sh - apply_layout_main_horizontal function exists" {
  function_exists apply_layout_main_horizontal
}

@test "main-horizontal.sh - apply_layout_main_horizontal succeeds with multiple panes" {
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}

@test "main-horizontal.sh - apply_layout_main_horizontal succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}

@test "main-horizontal.sh - apply_layout_main_horizontal succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}

@test "main-horizontal.sh - apply_layout_main_horizontal succeeds with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}

@test "main-horizontal.sh - apply_layout_main_horizontal succeeds with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}

@test "main-horizontal.sh - apply_layout_main_horizontal respects custom ratio" {
  export MOCK_TILING_MASTER_RATIO="70"
  run apply_layout_main_horizontal
  [[ "${status}" -eq 0 ]]
}
