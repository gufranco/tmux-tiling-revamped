#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_LAYOUT_HISTORY=""
  export MOCK_TILING_MASTER_RATIO="60"
  export MOCK_TILING_SPLIT_RATIO="50"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/undo-layout.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/info.sh"
}

teardown() {
  cleanup_test_environment
}

@test "info.sh - show_info function exists" {
  function_exists show_info
}

@test "info.sh - _decode_orientation function exists" {
  function_exists _decode_orientation
}

@test "info.sh - show_info outputs layout name" {
  run show_info
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"dwindle"* ]]
}

@test "info.sh - show_info outputs pane count" {
  run show_info
  [[ "${output}" == *"Panes:"* ]]
}

@test "info.sh - show_info outputs orientation" {
  run show_info
  [[ "${output}" == *"brvc"* ]]
}

@test "info.sh - show_info shows (none) when no layout set" {
  export MOCK_TILING_LAYOUT=""
  run show_info
  [[ "${output}" == *"(none)"* ]]
}

@test "info.sh - _decode_orientation decodes brvc" {
  run _decode_orientation "brvc"
  [[ "${output}" == "bottom-right, vertical, corner" ]]
}

@test "info.sh - _decode_orientation decodes tlhs" {
  run _decode_orientation "tlhs"
  [[ "${output}" == "top-left, horizontal, spiral" ]]
}

@test "info.sh - show_info includes undo depth" {
  run show_info
  [[ "${output}" == *"Undo depth:"* ]]
}

@test "info.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_INFO_LOADED}" ]]
  [[ "${_TILING_REVAMPED_INFO_LOADED}" == "1" ]]
}
