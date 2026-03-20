#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/tmux/tmux-ops.sh"
}

teardown() {
  cleanup_test_environment
}

@test "tmux-ops.sh - get_tmux_option returns option value" {
  export MOCK_TMUX_OPTION_VALUE="custom_value"
  run get_tmux_option "@tiling_revamped_test" "default"
  [[ "${output}" == "custom_value" ]]
}

@test "tmux-ops.sh - get_tmux_option returns default when option empty" {
  export MOCK_TMUX_OPTION_VALUE=""
  run get_tmux_option "@unknown_option" "fallback"
  [[ "${output}" == "fallback" ]]
}

@test "tmux-ops.sh - get_window_option returns window-scoped value" {
  export MOCK_TILING_LAYOUT="dwindle"
  run get_window_option "@tiling_revamped_layout" ""
  [[ "${output}" == "dwindle" ]]
}

@test "tmux-ops.sh - get_pane_option returns pane-scoped value" {
  export MOCK_TILING_MARK="editor"
  run get_pane_option "@tiling_revamped_mark" ""
  [[ "${output}" == "editor" ]]
}

@test "tmux-ops.sh - set_tmux_option does not error" {
  run set_tmux_option "@tiling_revamped_test" "value"
  [[ "${status}" -eq 0 ]]
}

@test "tmux-ops.sh - set_window_option does not error" {
  run set_window_option "@tiling_revamped_layout" "grid"
  [[ "${status}" -eq 0 ]]
}

@test "tmux-ops.sh - get_current_pane returns pane id" {
  export MOCK_PANE_ID="%3"
  run get_current_pane
  [[ "${output}" == "%3" ]]
}

@test "tmux-ops.sh - get_current_window returns window id" {
  export MOCK_WINDOW_ID="@2"
  run get_current_window
  [[ "${output}" == "@2" ]]
}

@test "tmux-ops.sh - get_pane_width returns numeric width" {
  export MOCK_PANE_WIDTH="120"
  run get_pane_width
  [[ "${output}" == "120" ]]
}

@test "tmux-ops.sh - get_pane_height returns numeric height" {
  export MOCK_PANE_HEIGHT="40"
  run get_pane_height
  [[ "${output}" == "40" ]]
}

@test "tmux-ops.sh - get_window_width returns numeric width" {
  export MOCK_WINDOW_WIDTH="200"
  run get_window_width
  [[ "${output}" == "200" ]]
}

@test "tmux-ops.sh - get_window_height returns numeric height" {
  export MOCK_WINDOW_HEIGHT="50"
  run get_window_height
  [[ "${output}" == "50" ]]
}

@test "tmux-ops.sh - get_pane_count returns count" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  run get_pane_count
  [[ "${output}" == "3" ]]
}

@test "tmux-ops.sh - get_tmux_option function is exported" {
  function_exists get_tmux_option
}

@test "tmux-ops.sh - get_window_option function is exported" {
  function_exists get_window_option
}

@test "tmux-ops.sh - set_tmux_option function is exported" {
  function_exists set_tmux_option
}

@test "tmux-ops.sh - get_current_pane function is exported" {
  function_exists get_current_pane
}
