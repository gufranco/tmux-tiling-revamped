#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_LAYOUT_HISTORY=""
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/undo-layout.sh"
}

teardown() {
  cleanup_test_environment
}

@test "undo-layout.sh - undo_layout function exists" {
  function_exists undo_layout
}

@test "undo-layout.sh - push_layout_history function exists" {
  function_exists push_layout_history
}

@test "undo-layout.sh - undo_layout returns 0 with empty history" {
  export MOCK_TILING_LAYOUT_HISTORY=""
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - push_layout_history succeeds" {
  run push_layout_history
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - push_layout_history does nothing when no layout set" {
  export MOCK_TILING_LAYOUT=""
  run push_layout_history
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout succeeds with valid history" {
  export MOCK_TILING_LAYOUT_HISTORY="grid:brvc"
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout succeeds with multi-entry history" {
  export MOCK_TILING_LAYOUT_HISTORY="grid:brvc|dwindle:brvc|spiral:brvs"
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout fails with unknown layout in history" {
  export MOCK_TILING_LAYOUT_HISTORY="nonexistent:brvc"
  run undo_layout
  [[ "${status}" -eq 1 ]]
}

@test "undo-layout.sh - TILING_MAX_UNDO_DEPTH is set to 10" {
  [[ "${TILING_MAX_UNDO_DEPTH}" -eq 10 ]]
}

@test "undo-layout.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED}" ]]
  [[ "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED}" == "1" ]]
}
