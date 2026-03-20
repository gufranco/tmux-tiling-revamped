#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/has-command.sh"
}

teardown() {
  cleanup_test_environment
}

@test "has-command.sh - has_command function exists" {
  function_exists has_command
}

@test "has-command.sh - has_command returns 0 for existing command" {
  has_command "bash"
}

@test "has-command.sh - has_command returns 1 for nonexistent command" {
  ! has_command "this_command_definitely_does_not_exist_xyz"
}

@test "has-command.sh - has_command works with common tools" {
  has_command "ls"
  has_command "cat"
}
