#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1'
  export MOCK_PANE_ID="%0"
  export MOCK_HAS_FZF="1"
  export MOCK_TILING_PROJECT_DIR=""
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/project-launcher.sh"
}

teardown() {
  cleanup_test_environment
}

@test "project-launcher.sh - launch_project function exists" {
  function_exists launch_project
}

@test "project-launcher.sh - launch_project fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project fails when project_dir is not set" {
  export MOCK_TILING_PROJECT_DIR=""
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project fails when project_dir does not exist" {
  export MOCK_TILING_PROJECT_DIR="/nonexistent/path/that/does/not/exist"
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project succeeds with valid directory" {
  export MOCK_TILING_PROJECT_DIR="${TEST_TMPDIR}"
  mkdir -p "${TEST_TMPDIR}/project-a"
  # fzf will exit with no selection in non-interactive mode
  run launch_project
  # Returns 0 on empty selection (graceful exit)
  [[ "${status}" -eq 0 ]]
}

@test "project-launcher.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED}" ]]
  [[ "${_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED}" == "1" ]]
}
