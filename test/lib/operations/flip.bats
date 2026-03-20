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
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/flip.sh"
}

teardown() {
  cleanup_test_environment
}

@test "flip.sh - flip_layout function exists" {
  function_exists flip_layout
}

@test "flip.sh - flip_layout horizontal succeeds" {
  run flip_layout "h"
  [[ "${status}" -eq 0 ]]
}

@test "flip.sh - flip_layout vertical succeeds" {
  run flip_layout "v"
  [[ "${status}" -eq 0 ]]
}

@test "flip.sh - flip_layout defaults to horizontal" {
  run flip_layout
  [[ "${status}" -eq 0 ]]
}

@test "flip.sh - flip_layout fails with invalid direction" {
  run flip_layout "x"
  [[ "${status}" -ne 0 ]]
}

@test "flip.sh - flip_layout skips non-BSP layouts" {
  export MOCK_TILING_LAYOUT="grid"
  run flip_layout "h"
  [[ "${status}" -eq 0 ]]
}
