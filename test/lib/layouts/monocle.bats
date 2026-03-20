#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_WINDOW_ZOOMED="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
}

teardown() {
  cleanup_test_environment
}

@test "monocle.sh - apply_layout_monocle function exists" {
  function_exists apply_layout_monocle
}

@test "monocle.sh - apply_layout_monocle succeeds when not zoomed" {
  export MOCK_WINDOW_ZOOMED="0"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle succeeds when already zoomed" {
  export MOCK_WINDOW_ZOOMED="1"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle toggles off when already in monocle" {
  export MOCK_WINDOW_ZOOMED="1"
  export MOCK_TILING_LAYOUT="monocle"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}

@test "monocle.sh - apply_layout_monocle works with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_monocle
  [[ "${status}" -eq 0 ]]
}
