#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_ORIENTATION="brvs"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
}

teardown() {
  cleanup_test_environment
}

# ── Function existence ──────────────────────────────────────────────

@test "spiral.sh - apply_layout_spiral function exists" {
  function_exists apply_layout_spiral
}

# ── Basic operation ──────────────────────────────────────────────────

@test "spiral.sh - apply_layout_spiral succeeds with multiple panes" {
  run apply_layout_spiral "brvs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral forces spiral trajectory" {
  run apply_layout_spiral "brvc"
  [[ "${status}" -eq 0 ]]
}

# ── Pane count coverage ─────────────────────────────────────────────

@test "spiral.sh - apply_layout_spiral works with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral works with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral works with 8 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral works with 10 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7\n%8\n%9'
  run apply_layout_spiral
  [[ "${status}" -eq 0 ]]
}

# ── Orientation variants ─────────────────────────────────────────────

@test "spiral.sh - apply_layout_spiral with horizontal orientation" {
  run apply_layout_spiral "brhs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral with top-left corner" {
  run apply_layout_spiral "tlvs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral with bottom-left corner" {
  run apply_layout_spiral "blvs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - apply_layout_spiral with top-right horizontal" {
  run apply_layout_spiral "trhs"
  [[ "${status}" -eq 0 ]]
}

@test "spiral.sh - all 16 BSP orientations succeed with spiral" {
  local orientations=(
    tlvc trvc blvc brvc
    tlvs trvs blvs brvs
    tlhc trhc blhc brhc
    tlhs trhs blhs brhs
  )
  for orient in "${orientations[@]}"; do
    run apply_layout_spiral "${orient}"
    [[ "${status}" -eq 0 ]]
  done
}

@test "spiral.sh - all 16 orientations succeed with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  local orientations=(
    tlvc trvc blvc brvc
    tlvs trvs blvs brvs
    tlhc trhc blhc brhc
    tlhs trhs blhs brhs
  )
  for orient in "${orientations[@]}"; do
    run apply_layout_spiral "${orient}"
    [[ "${status}" -eq 0 ]]
  done
}

# ── Spiral-specific geometry ─────────────────────────────────────────

@test "spiral.sh - spiral layout differs from dwindle for same panes" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1

  is_spiral=false
  local dwindle_result
  dwindle_result=$(_bsp_build "%0 %1 %2 %3 %4" 0 0 200 50 0)

  is_spiral=true
  local spiral_result
  spiral_result=$(_bsp_build "%0 %1 %2 %3 %4" 0 0 200 50 0)

  [[ "${dwindle_result}" != "${spiral_result}" ]]
}

@test "spiral.sh - spiral leaf permutation differs from identity for 5+ panes" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local perm
  perm=$(_bsp_leaf_permutation 5 0)
  [[ "${perm}" != "0 1 2 3 4" ]]
}

@test "spiral.sh - spiral and dwindle share first two pane positions" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1

  is_spiral=false
  local dwindle_result
  dwindle_result=$(_bsp_build "%0 %1 %2 %3 %4" 0 0 200 50 0)

  is_spiral=true
  local spiral_result
  spiral_result=$(_bsp_build "%0 %1 %2 %3 %4" 0 0 200 50 0)

  # Both start with same root and first two panes (depth 0,1 have no spiral reversal)
  local dwindle_prefix="${dwindle_result%%,1,*}"
  local spiral_prefix="${spiral_result%%,1,*}"
  [[ "${dwindle_prefix}" == "${spiral_prefix}" ]]
}
