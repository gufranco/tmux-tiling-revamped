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

@test "main-center.sh - apply_layout_main_center succeeds with 4 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 7 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 8 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center respects custom ratio" {
  export MOCK_TILING_MAIN_CENTER_RATIO="80"
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - _main_center_build produces balanced sides with 5 panes" {
  # 5 panes: 1 center + 2 left + 2 right
  run _main_center_build "%0 %1 %2 %3 %4" 200 50 60
  [[ "${status}" -eq 0 ]]
  # Left column should contain pane 1 and 2, right should contain 3 and 4
  [[ "${output}" == *",1"* ]]
  [[ "${output}" == *",2"* ]]
  [[ "${output}" == *",3"* ]]
  [[ "${output}" == *",4"* ]]
}

@test "main-center.sh - _main_center_build produces balanced sides with 7 panes" {
  # 7 panes: 1 center + 3 left + 3 right
  run _main_center_build "%0 %1 %2 %3 %4 %5 %6" 200 50 60
  [[ "${status}" -eq 0 ]]
  # All pane IDs present
  [[ "${output}" == *",0"* ]]
  [[ "${output}" == *",6"* ]]
}

@test "main-center.sh - _main_center_vstack produces vertical stack" {
  run _main_center_vstack "%1 %2 %3" 0 0 40 50
  [[ "${status}" -eq 0 ]]
  # Should contain vertical split markers
  [[ "${output}" == *"["* ]]
  [[ "${output}" == *",1"* ]]
  [[ "${output}" == *",2"* ]]
  [[ "${output}" == *",3"* ]]
}

@test "main-center.sh - _main_center_vstack single pane has no brackets" {
  run _main_center_vstack "%1" 0 0 40 50
  [[ "${status}" -eq 0 ]]
  [[ "${output}" != *"["* ]]
  [[ "${output}" == "40x50,0,0,1" ]]
}

@test "main-center.sh - preview variable updated to show balanced layout" {
  [[ "${TILING_PREVIEW_MAIN_CENTER}" == *"Balanced"* ]]
}
