#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_TILING_LAYOUT="dwindle"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/status.sh"
}

teardown() {
  cleanup_test_environment
}

@test "status.sh - layout_icon function exists" {
  function_exists layout_icon
}

@test "status.sh - layout_status function exists" {
  function_exists layout_status
}

@test "status.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_STATUS_LOADED}" == "1" ]]
}

@test "status.sh - layout_icon returns a glyph for every known layout" {
  local layout
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    run layout_icon "${layout}"
    [[ "${status}" -eq 0 ]]
    [[ -n "${output}" ]]
  done
}

@test "status.sh - layout_icon dwindle matches expected bytes" {
  run layout_icon "dwindle"
  [[ "${output}" == "$(printf '\xe2\x97\xa7')" ]]
}

@test "status.sh - layout_icon grid matches expected bytes" {
  run layout_icon "grid"
  [[ "${output}" == "$(printf '\xe2\x96\xa6')" ]]
}

@test "status.sh - layout_icon returns empty for an unknown layout" {
  run layout_icon "nonexistent"
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "status.sh - layout_icon returns empty for empty input" {
  run layout_icon ""
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "status.sh - layout_status renders icon and name for a known layout" {
  export MOCK_TILING_LAYOUT="spiral"
  run layout_status
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"spiral" ]]
  [[ "${output}" == "$(printf '\xe2\x97\x89')"" spiral" ]]
}

@test "status.sh - layout_status renders bare name when no icon maps" {
  export MOCK_TILING_LAYOUT="custom-layout"
  run layout_status
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "custom-layout" ]]
}

@test "status.sh - layout_status prints nothing when no layout is set" {
  export MOCK_TILING_LAYOUT=""
  run layout_status
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "status.sh - layout_status resolves every known layout name" {
  local layout
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    export MOCK_TILING_LAYOUT="${layout}"
    run layout_status
    [[ "${status}" -eq 0 ]]
    [[ "${output}" == *"${layout}" ]]
  done
}
