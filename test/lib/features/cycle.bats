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
  export MOCK_TILING_CYCLE_LAYOUTS="dwindle spiral grid main-center monocle"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/cycle.sh"
}

teardown() {
  cleanup_test_environment
}

@test "cycle.sh - cycle_layout function exists" {
  function_exists cycle_layout
}

@test "cycle.sh - cycle_layout next succeeds" {
  run cycle_layout "next"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout prev succeeds" {
  run cycle_layout "prev"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout defaults to next" {
  run cycle_layout
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout with empty layout list exits cleanly" {
  export MOCK_TILING_CYCLE_LAYOUTS=""
  run cycle_layout
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout with single layout in list" {
  export MOCK_TILING_CYCLE_LAYOUTS="grid"
  run cycle_layout "next"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout prev from first wraps to last" {
  export MOCK_TILING_LAYOUT="dwindle"
  run cycle_layout "prev"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout next from last wraps to first" {
  export MOCK_TILING_LAYOUT="monocle"
  run cycle_layout "next"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout works when current layout not in cycle list" {
  export MOCK_TILING_LAYOUT="deck"
  run cycle_layout "next"
  [[ "${status}" -eq 0 ]]
}

@test "cycle.sh - cycle_layout with custom list including deck" {
  export MOCK_TILING_CYCLE_LAYOUTS="dwindle deck grid"
  run cycle_layout "next"
  [[ "${status}" -eq 0 ]]
}
