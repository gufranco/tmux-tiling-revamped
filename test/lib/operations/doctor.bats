#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/doctor.sh"
}

teardown() {
  cleanup_test_environment
}

@test "doctor.sh - run_doctor function exists" {
  function_exists run_doctor
}

@test "doctor.sh - run_doctor succeeds" {
  run run_doctor
  [[ "${status}" -eq 0 ]]
}

@test "doctor.sh - run_doctor outputs bash version" {
  run run_doctor
  [[ "${output}" == *"bash"* ]]
}

@test "doctor.sh - run_doctor outputs tmux info" {
  run run_doctor
  [[ "${output}" == *"tmux"* ]]
}

@test "doctor.sh - run_doctor outputs plugin version" {
  run run_doctor
  [[ "${output}" == *"${TILING_REVAMPED_VERSION}"* ]]
}

@test "doctor.sh - run_doctor outputs current layout" {
  run run_doctor
  [[ "${output}" == *"dwindle"* ]]
}

@test "doctor.sh - run_doctor shows all checks passed" {
  run run_doctor
  [[ "${output}" == *"All checks passed"* ]]
}

@test "doctor.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_DOCTOR_LOADED}" ]]
  [[ "${_TILING_REVAMPED_DOCTOR_LOADED}" == "1" ]]
}
