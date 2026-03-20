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
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/rotate.sh"
}

teardown() {
  cleanup_test_environment
}

@test "rotate.sh - rotate_layout function exists" {
  function_exists rotate_layout
}

@test "rotate.sh - rotate_layout 90 succeeds" {
  run rotate_layout "90"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout 180 succeeds" {
  run rotate_layout "180"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout 270 succeeds" {
  run rotate_layout "270"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout defaults to 90" {
  run rotate_layout
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout fails with invalid degrees" {
  run rotate_layout "45"
  [[ "${status}" -ne 0 ]]
}

@test "rotate.sh - rotate_layout skips non-BSP layouts" {
  export MOCK_TILING_LAYOUT="grid"
  run rotate_layout "90"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout works with spiral layout" {
  export MOCK_TILING_LAYOUT="spiral"
  run rotate_layout "90"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout skips monocle layout" {
  export MOCK_TILING_LAYOUT="monocle"
  run rotate_layout "90"
  [[ "${status}" -eq 0 ]]
}

@test "rotate.sh - rotate_layout with horizontal orientation" {
  export MOCK_TILING_ORIENTATION="brhc"
  run rotate_layout "90"
  [[ "${status}" -eq 0 ]]
}
