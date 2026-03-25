#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="main-vertical"
  export MOCK_TILING_MASTER_RATIO="60"
  export MOCK_TILING_RESIZE_STEP="5"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/resize-master.sh"
}

teardown() {
  cleanup_test_environment
}

@test "resize-master.sh - resize_master function exists" {
  function_exists resize_master
}

@test "resize-master.sh - resize_master grow succeeds" {
  run resize_master "grow"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master shrink succeeds" {
  run resize_master "shrink"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master defaults to grow" {
  run resize_master
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run resize_master "grow"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master works with main-horizontal" {
  export MOCK_TILING_LAYOUT="main-horizontal"
  run resize_master "grow"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master works with main-center" {
  export MOCK_TILING_LAYOUT="main-center"
  run resize_master "shrink"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master works with dwindle (direct resize)" {
  export MOCK_TILING_LAYOUT="dwindle"
  run resize_master "grow"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master works with grid (direct resize)" {
  export MOCK_TILING_LAYOUT="grid"
  run resize_master "shrink"
  [[ "${status}" -eq 0 ]]
}

@test "resize-master.sh - resize_master works with no layout set" {
  export MOCK_TILING_LAYOUT=""
  run resize_master "grow"
  [[ "${status}" -eq 0 ]]
}
