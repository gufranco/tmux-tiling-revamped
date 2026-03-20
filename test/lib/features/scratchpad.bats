#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/scratchpad.sh"
}

teardown() {
  cleanup_test_environment
}

@test "scratchpad.sh - toggle_scratchpad function exists" {
  function_exists toggle_scratchpad
}

@test "scratchpad.sh - toggle_scratchpad with default name succeeds" {
  run toggle_scratchpad
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad with custom name succeeds" {
  run toggle_scratchpad "htop"
  [[ "${status}" -eq 0 ]]
}

@test "scratchpad.sh - toggle_scratchpad sanitizes name" {
  run toggle_scratchpad 'my scratch!pad'
  [[ "${status}" -eq 0 ]]
}
