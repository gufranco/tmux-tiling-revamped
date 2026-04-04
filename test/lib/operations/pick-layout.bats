#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/pick-layout.sh"
}

teardown() {
  cleanup_test_environment
}

@test "pick-layout.sh - pick_layout function exists" {
  function_exists pick_layout
}

@test "pick-layout.sh - _get_layout_preview function exists" {
  function_exists _get_layout_preview
}

@test "pick-layout.sh - _get_layout_list function exists" {
  function_exists _get_layout_list
}

@test "pick-layout.sh - _fzf_supports_tmux_popup function exists" {
  function_exists _fzf_supports_tmux_popup
}

@test "pick-layout.sh - PICK_LAYOUTS array contains all 8 layouts" {
  [[ "${#PICK_LAYOUTS[@]}" -eq 8 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains dwindle" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "dwindle" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains spiral" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "spiral" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains grid" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "grid" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-vertical" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-vertical" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-horizontal" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-horizontal" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-center" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-center" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains monocle" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "monocle" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains deck" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "deck" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - _get_layout_list outputs all layouts" {
  run _get_layout_list
  [[ "${status}" -eq 0 ]]
  local line_count
  line_count=$(echo "${output}" | wc -l | tr -d ' ')
  [[ "${line_count}" -eq 8 ]]
}

@test "pick-layout.sh - _get_layout_list first item is dwindle" {
  run _get_layout_list
  local first_line
  first_line=$(echo "${output}" | head -1)
  [[ "${first_line}" == "dwindle" ]]
}

@test "pick-layout.sh - _get_layout_preview returns dwindle preview" {
  run _get_layout_preview "dwindle"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Dwindle Layout"* ]]
  [[ "${output}" == *"BSP cascade toward corner"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns spiral preview" {
  run _get_layout_preview "spiral"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Spiral Layout"* ]]
  [[ "${output}" == *"BSP with spiral trajectory"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns grid preview" {
  run _get_layout_preview "grid"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Grid Layout"* ]]
  [[ "${output}" == *"Even N x M grid distribution"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-vertical preview" {
  run _get_layout_preview "main-vertical"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Vertical"* ]]
  [[ "${output}" == *"Master left, stack right"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-horizontal preview" {
  run _get_layout_preview "main-horizontal"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Horizontal"* ]]
  [[ "${output}" == *"Master top, stack bottom"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-center preview" {
  run _get_layout_preview "main-center"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Center"* ]]
  [[ "${output}" == *"center pane"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns monocle preview" {
  run _get_layout_preview "monocle"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Monocle Layout"* ]]
  [[ "${output}" == *"Zoom focused pane to fullscreen"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns deck preview" {
  run _get_layout_preview "deck"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Deck Layout"* ]]
  [[ "${output}" == *"Full-height equal-width cards"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns fallback for unknown layout" {
  run _get_layout_preview "nonexistent"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "No preview available" ]]
}

@test "pick-layout.sh - _get_layout_preview returns fallback for empty input" {
  run _get_layout_preview ""
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "No preview available" ]]
}

@test "pick-layout.sh - pick_layout fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run pick_layout
  [[ "${status}" -eq 1 ]]
}

@test "pick-layout.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_PICK_LAYOUT_LOADED}" ]]
  [[ "${_TILING_REVAMPED_PICK_LAYOUT_LOADED}" == "1" ]]
}

@test "pick-layout.sh - all layout preview variables are exported" {
  [[ -n "${TILING_PREVIEW_DWINDLE}" ]]
  [[ -n "${TILING_PREVIEW_SPIRAL}" ]]
  [[ -n "${TILING_PREVIEW_GRID}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_VERTICAL}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_HORIZONTAL}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_CENTER}" ]]
  [[ -n "${TILING_PREVIEW_MONOCLE}" ]]
  [[ -n "${TILING_PREVIEW_DECK}" ]]
}

@test "pick-layout.sh - preview variables contain ASCII box drawing characters" {
  [[ "${TILING_PREVIEW_DWINDLE}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_SPIRAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_GRID}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_VERTICAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_HORIZONTAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_CENTER}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MONOCLE}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_DECK}" == *"┌"* ]]
}
