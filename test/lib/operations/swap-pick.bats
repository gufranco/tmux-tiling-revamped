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
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/swap-pick.sh"
}

teardown() {
  cleanup_test_environment
}

@test "swap-pick.sh - swap_pick function exists" {
  function_exists swap_pick
}

@test "swap-pick.sh - swap_pick fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run swap_pick
  [[ "${status}" -eq 1 ]]
}

@test "swap-pick.sh - swap_pick returns 0 with single pane" {
  export MOCK_PANE_LIST="%0"
  run swap_pick
  [[ "${status}" -eq 0 ]]
}

@test "swap-pick.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_SWAP_PICK_LOADED}" ]]
  [[ "${_TILING_REVAMPED_SWAP_PICK_LOADED}" == "1" ]]
}
