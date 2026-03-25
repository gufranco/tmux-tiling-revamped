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
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/swap-direction.sh"
}

teardown() {
  cleanup_test_environment
}

@test "swap-direction.sh - swap_pane_direction function exists" {
  function_exists swap_pane_direction
}

@test "swap-direction.sh - swap_pane_direction R succeeds" {
  run swap_pane_direction "R"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction L succeeds" {
  run swap_pane_direction "L"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction U succeeds" {
  run swap_pane_direction "U"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction D succeeds" {
  run swap_pane_direction "D"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction defaults to R" {
  run swap_pane_direction
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run swap_pane_direction "R"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with grid layout" {
  export MOCK_TILING_LAYOUT="grid"
  run swap_pane_direction "R"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with deck layout" {
  export MOCK_TILING_LAYOUT="deck"
  run swap_pane_direction "L"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with main-vertical" {
  export MOCK_TILING_LAYOUT="main-vertical"
  run swap_pane_direction "R"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with main-horizontal" {
  export MOCK_TILING_LAYOUT="main-horizontal"
  run swap_pane_direction "D"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with main-center" {
  export MOCK_TILING_LAYOUT="main-center"
  run swap_pane_direction "L"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with spiral" {
  export MOCK_TILING_LAYOUT="spiral"
  export MOCK_TILING_ORIENTATION="brvs"
  run swap_pane_direction "U"
  [[ "${status}" -eq 0 ]]
}

@test "swap-direction.sh - swap_pane_direction works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run swap_pane_direction "R"
  [[ "${status}" -eq 0 ]]
}
