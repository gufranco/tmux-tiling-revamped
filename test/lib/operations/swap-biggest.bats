#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT=""
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/swap-biggest.sh"
}

teardown() {
  cleanup_test_environment
}

@test "swap-biggest.sh - swap_biggest function exists" {
  function_exists swap_biggest
}

@test "swap-biggest.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_SWAP_BIGGEST_LOADED}" == "1" ]]
}

@test "swap-biggest.sh - exits early with a single pane" {
  export MOCK_PANE_LIST="%0 200 50"
  export MOCK_PANE_ID="%0"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}

@test "swap-biggest.sh - swaps focused pane with the largest pane" {
  export MOCK_PANE_LIST=$'%0 100 50\n%1 50 50\n%2 50 25'
  export MOCK_PANE_ID="%1"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}

@test "swap-biggest.sh - no-op when the focused pane is already the largest" {
  export MOCK_PANE_LIST=$'%0 100 50\n%1 50 50\n%2 50 25'
  export MOCK_PANE_ID="%0"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}

@test "swap-biggest.sh - skips blank and malformed geometry lines" {
  export MOCK_PANE_LIST=$'\n%0 abc 50\n%1 50 xy\n%2 80 40'
  export MOCK_PANE_ID="%9"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}

@test "swap-biggest.sh - returns 0 when no valid pane geometry is found" {
  export MOCK_PANE_LIST=$'\n%0 abc 50\nbroken'
  export MOCK_PANE_ID="%9"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}

@test "swap-biggest.sh - returns 1 when the swap fails" {
  export MOCK_PANE_LIST=$'%0 100 50\n%1 50 50\n%2 50 25'
  export MOCK_PANE_ID="%1"
  tmux() {
    case "$1" in
      list-panes) printf '%s\n' "${MOCK_PANE_LIST}" ;;
      display-message) echo "${MOCK_PANE_ID}" ;;
      swap-pane) return 1 ;;
      *) return 0 ;;
    esac
    return 0
  }
  export -f tmux
  run swap_biggest
  [[ "${status}" -eq 1 ]]
}

@test "swap-biggest.sh - swaps and re-applies a grid layout" {
  export MOCK_TILING_LAYOUT="grid"
  export MOCK_PANE_LIST=$'%0 100 50\n%1 50 50\n%2 50 25'
  export MOCK_PANE_ID="%2"
  run swap_biggest
  [[ "${status}" -eq 0 ]]
}
