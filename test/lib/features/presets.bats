#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_MAIN_CENTER_RATIO="60"
  export MOCK_HAS_FZF="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/presets.sh"
}

teardown() {
  cleanup_test_environment
}

@test "presets.sh - save_preset function exists" {
  function_exists save_preset
}

@test "presets.sh - apply_preset function exists" {
  function_exists apply_preset
}

@test "presets.sh - save_preset succeeds with valid name" {
  run save_preset "dev"
  [[ "${status}" -eq 0 ]]
}

@test "presets.sh - save_preset fails with empty name" {
  run save_preset ""
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - save_preset sanitizes special characters" {
  run save_preset 'my preset!'
  [[ "${status}" -eq 0 ]]
}

@test "presets.sh - apply_preset fails with empty name and no fzf" {
  export MOCK_HAS_FZF="0"
  run apply_preset ""
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - apply_preset fails with nonexistent preset" {
  export MOCK_TMUX_OPTION_VALUE=""
  run apply_preset "nonexistent"
  [[ "${status}" -ne 0 ]]
}
