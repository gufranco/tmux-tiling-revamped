#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_ID="%2"
  export MOCK_TILING_MARKS=""
  export MOCK_TILING_MARK=""
  export MOCK_HAS_FZF="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/marks.sh"
}

teardown() {
  cleanup_test_environment
}

@test "marks.sh - mark_pane function exists" {
  function_exists mark_pane
}

@test "marks.sh - unmark_pane function exists" {
  function_exists unmark_pane
}

@test "marks.sh - jump_to_mark function exists" {
  function_exists jump_to_mark
}

@test "marks.sh - mark_pane succeeds with valid name" {
  run mark_pane "editor"
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - mark_pane fails with empty name" {
  run mark_pane ""
  [[ "${status}" -ne 0 ]]
}

@test "marks.sh - mark_pane sanitizes special characters" {
  run mark_pane 'e d!i@t#o$r'
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - unmark_pane succeeds" {
  export MOCK_TILING_MARK="editor"
  run unmark_pane
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - jump_to_mark fails without fzf when no name given" {
  export MOCK_HAS_FZF="0"
  run jump_to_mark ""
  [[ "${status}" -ne 0 ]]
}

@test "marks.sh - mark_pane with dashes and underscores" {
  run mark_pane "my-editor_pane"
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - unmark_pane with specific name" {
  run unmark_pane "editor"
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - unmark_pane with no existing marks" {
  export MOCK_TILING_MARK=""
  export MOCK_TILING_MARKS=""
  run unmark_pane
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - jump_to_mark with specific name succeeds" {
  export MOCK_TILING_MARKS="editor:%2"
  run jump_to_mark "editor"
  [[ "${status}" -eq 0 ]]
}

@test "marks.sh - jump_to_mark with nonexistent name fails" {
  export MOCK_TILING_MARKS="editor:%2"
  run jump_to_mark "nonexistent"
  [[ "${status}" -ne 0 ]]
}

@test "marks.sh - mark_pane only keeps alphanumeric, dashes, and underscores" {
  run mark_pane '!@#$%'
  [[ "${status}" -ne 0 ]]
}
