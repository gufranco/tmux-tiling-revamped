#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
}

teardown() {
  cleanup_test_environment
}

@test "constants.sh - TILING_REVAMPED_VERSION is set" {
  [[ -n "${TILING_REVAMPED_VERSION}" ]]
  [[ "${TILING_REVAMPED_VERSION}" == "1.0.0" ]]
}

@test "constants.sh - TILING_DEFAULT_ORIENTATION is set" {
  [[ -n "${TILING_DEFAULT_ORIENTATION}" ]]
  [[ "${TILING_DEFAULT_ORIENTATION}" == "brvc" ]]
}

@test "constants.sh - TILING_DEFAULT_MASTER_RATIO is set" {
  [[ -n "${TILING_DEFAULT_MASTER_RATIO}" ]]
  [[ "${TILING_DEFAULT_MASTER_RATIO}" == "60" ]]
}

@test "constants.sh - TILING_DEFAULT_SPLIT_RATIO is set" {
  [[ -n "${TILING_DEFAULT_SPLIT_RATIO}" ]]
  [[ "${TILING_DEFAULT_SPLIT_RATIO}" == "50" ]]
}

@test "constants.sh - TILING_DEFAULT_FOCUS_RATIO is set" {
  [[ -n "${TILING_DEFAULT_FOCUS_RATIO}" ]]
  [[ "${TILING_DEFAULT_FOCUS_RATIO}" == "62" ]]
}

@test "constants.sh - OPT_LAYOUT is set" {
  [[ -n "${OPT_LAYOUT}" ]]
  [[ "${OPT_LAYOUT}" == "@tiling_revamped_layout" ]]
}

@test "constants.sh - OPT_APPLYING is set" {
  [[ -n "${OPT_APPLYING}" ]]
  [[ "${OPT_APPLYING}" == "@tiling_revamped_applying" ]]
}

@test "constants.sh - OPT_AUTO_APPLY is set" {
  [[ -n "${OPT_AUTO_APPLY}" ]]
  [[ "${OPT_AUTO_APPLY}" == "@tiling_revamped_auto_apply" ]]
}

@test "constants.sh - all keybinding option constants are set" {
  [[ -n "${OPT_KEY_DWINDLE}" ]]
  [[ -n "${OPT_KEY_SPIRAL}" ]]
  [[ -n "${OPT_KEY_BALANCE}" ]]
  [[ -n "${OPT_KEY_EQUALIZE}" ]]
  [[ -n "${OPT_KEY_PROMOTE}" ]]
  [[ -n "${OPT_KEY_ROTATE}" ]]
  [[ -n "${OPT_KEY_FLIP}" ]]
  [[ -n "${OPT_KEY_CIRCULATE}" ]]
  [[ -n "${OPT_KEY_AUTOTILE}" ]]
  [[ -n "${OPT_KEY_CYCLE}" ]]
  [[ -n "${OPT_KEY_MARK}" ]]
  [[ -n "${OPT_KEY_JUMP}" ]]
  [[ -n "${OPT_KEY_SCRATCHPAD}" ]]
}

@test "constants.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_CONSTANTS_LOADED}" ]]
  [[ "${_TILING_REVAMPED_CONSTANTS_LOADED}" == "1" ]]
}
