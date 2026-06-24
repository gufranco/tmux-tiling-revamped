#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/previews.sh"
}

teardown() {
  cleanup_test_environment
}

@test "previews.sh - every layout preview is exported and non-empty" {
  [[ -n "${TILING_PREVIEW_DECK}" ]]
  [[ -n "${TILING_PREVIEW_DWINDLE}" ]]
  [[ -n "${TILING_PREVIEW_GRID}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_CENTER}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_HORIZONTAL}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_VERTICAL}" ]]
  [[ -n "${TILING_PREVIEW_MONOCLE}" ]]
  [[ -n "${TILING_PREVIEW_SPIRAL}" ]]
}

@test "previews.sh - the main-center preview shows the balanced layout" {
  [[ "${TILING_PREVIEW_MAIN_CENTER}" == *"Balanced"* ]]
}

@test "previews.sh - the source guard prevents double loading" {
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/previews.sh"
  [[ "${_TILING_REVAMPED_PREVIEWS_LOADED}" == "1" ]]
}
