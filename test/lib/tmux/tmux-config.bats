#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/tmux/tmux-config.sh"
}

teardown() {
  cleanup_test_environment
}

@test "tmux-config.sh - is_option_enabled returns true for 1" {
  export MOCK_TILING_AUTO_APPLY="1"
  is_option_enabled "@tiling_revamped_auto_apply"
}

@test "tmux-config.sh - is_option_enabled returns true for true" {
  export MOCK_TMUX_OPTION_VALUE="true"
  is_option_enabled "@tiling_revamped_custom_bool"
}

@test "tmux-config.sh - is_option_enabled returns false for 0" {
  export MOCK_TILING_FOCUS_RESIZE="0"
  ! is_option_enabled "@tiling_revamped_focus_resize"
}

@test "tmux-config.sh - is_option_enabled returns false for empty" {
  export MOCK_TMUX_OPTION_VALUE=""
  ! is_option_enabled "@tiling_revamped_nonexistent"
}

@test "tmux-config.sh - get_numeric_option returns valid number" {
  export MOCK_TILING_FOCUS_RATIO="75"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62"
  [[ "${output}" == "75" ]]
}

@test "tmux-config.sh - get_numeric_option returns default for non-numeric" {
  export MOCK_TMUX_OPTION_VALUE="abc"
  run get_numeric_option "@tiling_revamped_custom_num" "50"
  [[ "${output}" == "50" ]]
}

@test "tmux-config.sh - get_numeric_option clamps to min" {
  export MOCK_TILING_FOCUS_RATIO="5"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62" "10" "90"
  [[ "${output}" == "10" ]]
}

@test "tmux-config.sh - get_numeric_option clamps to max" {
  export MOCK_TILING_FOCUS_RATIO="95"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62" "10" "90"
  [[ "${output}" == "90" ]]
}

@test "tmux-config.sh - get_current_layout returns stored layout" {
  export MOCK_TILING_LAYOUT="dwindle"
  run get_current_layout
  [[ "${output}" == "dwindle" ]]
}

@test "tmux-config.sh - get_current_layout returns empty when unset" {
  export MOCK_TILING_LAYOUT=""
  run get_current_layout
  [[ "${output}" == "" ]]
}

@test "tmux-config.sh - set_current_layout does not error" {
  run set_current_layout "spiral"
  [[ "${status}" -eq 0 ]]
}

@test "tmux-config.sh - is_applying returns false by default" {
  export MOCK_TILING_APPLYING="0"
  ! is_applying
}

@test "tmux-config.sh - is_applying returns true when set" {
  export MOCK_TILING_APPLYING="1"
  is_applying
}

@test "tmux-config.sh - set_applying does not error" {
  run set_applying 1
  [[ "${status}" -eq 0 ]]
}

@test "tmux-config.sh - is_auto_apply_enabled checks window override first" {
  export MOCK_TILING_ENABLED="0"
  export MOCK_TILING_AUTO_APPLY="1"
  ! is_auto_apply_enabled
}

@test "tmux-config.sh - is_auto_apply_enabled falls back to global" {
  export MOCK_TILING_ENABLED=""
  export MOCK_TILING_AUTO_APPLY="1"
  is_auto_apply_enabled
}

@test "tmux-config.sh - is_option_enabled function is exported" {
  function_exists is_option_enabled
}

@test "tmux-config.sh - get_numeric_option function is exported" {
  function_exists get_numeric_option
}

@test "tmux-config.sh - is_applying function is exported" {
  function_exists is_applying
}
