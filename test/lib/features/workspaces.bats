#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/workspaces.sh"
}

teardown() {
  cleanup_test_environment
}

@test "workspaces.sh - switch_workspace function exists" {
  function_exists switch_workspace
}

@test "workspaces.sh - move_to_workspace function exists" {
  function_exists move_to_workspace
}

@test "workspaces.sh - switch_workspace succeeds with valid number" {
  run switch_workspace 1
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - switch_workspace succeeds with number 9" {
  run switch_workspace 9
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - switch_workspace fails with non-numeric input" {
  run switch_workspace "abc"
  [[ "${status}" -eq 1 ]]
}

@test "workspaces.sh - switch_workspace defaults to 1" {
  run switch_workspace
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - move_to_workspace succeeds with valid number" {
  run move_to_workspace 2
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - move_to_workspace fails with non-numeric input" {
  run move_to_workspace "xyz"
  [[ "${status}" -eq 1 ]]
}

@test "workspaces.sh - move_to_workspace defaults to 1" {
  run move_to_workspace
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_WORKSPACES_LOADED}" ]]
  [[ "${_TILING_REVAMPED_WORKSPACES_LOADED}" == "1" ]]
}

@test "workspaces.sh - record_last_window function exists" {
  function_exists record_last_window
}

@test "workspaces.sh - workspace_back_and_forth function exists" {
  function_exists workspace_back_and_forth
}

@test "workspaces.sh - record_last_window stores the current window id" {
  export MOCK_WINDOW_ID="@5"
  local cap="${TEST_TMPDIR}/last.txt"
  set_tmux_option() { printf '%s|%s\n' "$1" "$2" >> "${cap}"; }
  export -f set_tmux_option
  run record_last_window
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_last_window|@5' "${cap}"
}

@test "workspaces.sh - record_last_window is a no-op with no current window" {
  get_current_window() { echo ""; }
  export -f get_current_window
  local cap="${TEST_TMPDIR}/none.txt"
  set_tmux_option() { echo "$1" >> "${cap}"; }
  export -f set_tmux_option
  run record_last_window
  [[ "${status}" -eq 0 ]]
  [[ ! -f "${cap}" ]]
}

@test "workspaces.sh - switch_workspace records the window it leaves" {
  export MOCK_WINDOW_ID="@2"
  local cap="${TEST_TMPDIR}/leave.txt"
  set_tmux_option() { printf '%s|%s\n' "$1" "$2" >> "${cap}"; }
  export -f set_tmux_option
  run switch_workspace 3
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_last_window|@2' "${cap}"
}

@test "workspaces.sh - back_and_forth returns 0 when nothing is recorded" {
  export MOCK_TILING_LAST_WINDOW=""
  run workspace_back_and_forth
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - back_and_forth no-op when last equals current window" {
  export MOCK_TILING_LAST_WINDOW="@0"
  export MOCK_WINDOW_ID="@0"
  run workspace_back_and_forth
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - back_and_forth switches to the recorded window" {
  export MOCK_TILING_LAST_WINDOW="@7"
  export MOCK_WINDOW_ID="@1"
  run workspace_back_and_forth
  [[ "${status}" -eq 0 ]]
}

@test "workspaces.sh - back_and_forth swaps the recorded window before switching" {
  export MOCK_TILING_LAST_WINDOW="@7"
  export MOCK_WINDOW_ID="@1"
  local cap="${TEST_TMPDIR}/swap.txt"
  set_tmux_option() { printf '%s|%s\n' "$1" "$2" >> "${cap}"; }
  export -f set_tmux_option
  run workspace_back_and_forth
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_last_window|@1' "${cap}"
}

@test "workspaces.sh - back_and_forth returns 1 when the switch fails" {
  export MOCK_TILING_LAST_WINDOW="@7"
  export MOCK_WINDOW_ID="@1"
  tmux() {
    case "$1" in
      show-option) echo "${MOCK_TILING_LAST_WINDOW}" ;;
      display-message) echo "${MOCK_WINDOW_ID}" ;;
      select-window) return 1 ;;
      *) return 0 ;;
    esac
    return 0
  }
  export -f tmux
  run workspace_back_and_forth
  [[ "${status}" -eq 1 ]]
}
