#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/pane-guard.sh"
}

teardown() {
  cleanup_test_environment
}

@test "pane-guard.sh - check_pane_size function exists" {
  function_exists check_pane_size
}

@test "pane-guard.sh - returns 0 for single pane" {
  run check_pane_size 1 200 50 "dwindle"
  [[ "${status}" -eq 0 ]]
}

@test "pane-guard.sh - returns 0 for reasonable pane count" {
  run check_pane_size 4 200 50 "dwindle"
  [[ "${status}" -eq 0 ]]
}

@test "pane-guard.sh - returns 0 for grid with 4 panes" {
  run check_pane_size 4 200 50 "grid"
  [[ "${status}" -eq 0 ]]
}

@test "pane-guard.sh - returns 0 for deck with 4 panes" {
  run check_pane_size 4 200 50 "deck"
  [[ "${status}" -eq 0 ]]
}

@test "pane-guard.sh - returns 1 for too many BSP panes in small window" {
  run check_pane_size 20 40 20 "dwindle"
  [[ "${status}" -eq 1 ]]
}

@test "pane-guard.sh - returns 1 for too many deck panes in narrow window" {
  run check_pane_size 20 40 20 "deck"
  [[ "${status}" -eq 1 ]]
}

@test "pane-guard.sh - returns 0 for unknown layout" {
  run check_pane_size 10 200 50 "custom"
  [[ "${status}" -eq 0 ]]
}

@test "pane-guard.sh - defaults are set" {
  [[ "${TILING_DEFAULT_MIN_PANE_WIDTH}" -eq 10 ]]
  [[ "${TILING_DEFAULT_MIN_PANE_HEIGHT}" -eq 5 ]]
}

@test "pane-guard.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_PANE_GUARD_LOADED}" ]]
  [[ "${_TILING_REVAMPED_PANE_GUARD_LOADED}" == "1" ]]
}
