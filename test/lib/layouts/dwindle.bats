#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
}

teardown() {
  cleanup_test_environment
}

@test "dwindle.sh - apply_layout_dwindle function exists" {
  function_exists apply_layout_dwindle
}

@test "dwindle.sh - _apply_bsp_layout function exists" {
  function_exists _apply_bsp_layout
}

@test "dwindle.sh - apply_layout_dwindle succeeds with multiple panes" {
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_dwindle
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - _apply_bsp_layout with is_spiral false uses corner trajectory" {
  run _apply_bsp_layout "false" "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - _apply_bsp_layout with is_spiral true uses spiral trajectory" {
  run _apply_bsp_layout "true" "brvs"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle accepts top-left orientation" {
  run apply_layout_dwindle "tlvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle accepts horizontal branch direction" {
  run apply_layout_dwindle "brhc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle reads orientation from options when no arg" {
  export MOCK_TILING_ORIENTATION="tlhc"
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  run apply_layout_dwindle
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - all 16 BSP orientations succeed" {
  local orientations=(
    tlvc trvc blvc brvc
    tlvs trvs blvs brvs
    tlhc trhc blhc brhc
    tlhs trhs blhs brhs
  )
  for orient in "${orientations[@]}"; do
    run apply_layout_dwindle "${orient}"
    [[ "${status}" -eq 0 ]]
  done
}
