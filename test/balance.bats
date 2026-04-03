#!/usr/bin/env bats
#
# Balance invariant tests: verify every layout produces balanced pane
# distribution at pane counts from 1 up to the maximum the test
# server supports (200x50 window, typically 10-12 panes).
#
# A layout is balanced when no column or row zone has more than 1
# pane difference from any other zone in the same group.

load "${BATS_TEST_DIRNAME}/tmux_helpers.bash"

setup() {
  setup_tmux_server
}

teardown() {
  teardown_tmux_server
}

# ── Dwindle ────────────────────────────────────────────────────────

@test "balance: dwindle applies at 1 pane" {
  assert_layout_applies dwindle 1
}

@test "balance: dwindle applies at 2 panes" {
  assert_layout_applies dwindle 2
}

@test "balance: dwindle applies at 3 panes" {
  assert_layout_applies dwindle 3
}

@test "balance: dwindle applies at 4 panes" {
  assert_layout_applies dwindle 4
}

@test "balance: dwindle applies at 5 panes" {
  assert_layout_applies dwindle 5
}

@test "balance: dwindle applies at 6 panes" {
  assert_layout_applies dwindle 6
}

@test "balance: dwindle applies at 7 panes" {
  assert_layout_applies dwindle 7
}

@test "balance: dwindle applies at 8 panes" {
  assert_layout_applies dwindle 8
}

@test "balance: dwindle applies at 9 panes" {
  assert_layout_applies dwindle 9
}

@test "balance: dwindle applies at 10 panes" {
  assert_layout_applies dwindle 10
}

# ── Spiral ─────────────────────────────────────────────────────────

@test "balance: spiral applies at 2 panes" {
  assert_layout_applies spiral 2
}

@test "balance: spiral applies at 4 panes" {
  assert_layout_applies spiral 4
}

@test "balance: spiral applies at 6 panes" {
  assert_layout_applies spiral 6
}

@test "balance: spiral applies at 8 panes" {
  assert_layout_applies spiral 8
}

@test "balance: spiral applies at 10 panes" {
  assert_layout_applies spiral 10
}

# ── Grid ───────────────────────────────────────────────────────────

@test "balance: grid applies at 1 pane" {
  assert_layout_applies grid 1
}

@test "balance: grid applies at 2 panes" {
  assert_layout_applies grid 2
}

@test "balance: grid applies at 4 panes" {
  assert_layout_applies grid 4
}

@test "balance: grid applies at 6 panes" {
  assert_layout_applies grid 6
}

@test "balance: grid applies at 9 panes" {
  assert_layout_applies grid 9
}

# ── Main-Vertical ──────────────────────────────────────────────────

@test "balance: main-vertical applies at 1 pane" {
  assert_layout_applies main-vertical 1
}

@test "balance: main-vertical applies at 2 panes" {
  assert_layout_applies main-vertical 2
}

@test "balance: main-vertical applies at 3 panes" {
  assert_layout_applies main-vertical 3
  assert_balanced_rows main-vertical
}

@test "balance: main-vertical applies at 5 panes" {
  assert_layout_applies main-vertical 5
  assert_balanced_rows main-vertical
}

@test "balance: main-vertical applies at 7 panes" {
  assert_layout_applies main-vertical 7
  assert_balanced_rows main-vertical
}

@test "balance: main-vertical applies at 9 panes" {
  assert_layout_applies main-vertical 9
  assert_balanced_rows main-vertical
}

# ── Main-Horizontal ───────────────────────────────────────────────

@test "balance: main-horizontal applies at 1 pane" {
  assert_layout_applies main-horizontal 1
}

@test "balance: main-horizontal applies at 2 panes" {
  assert_layout_applies main-horizontal 2
}

@test "balance: main-horizontal applies at 3 panes" {
  assert_layout_applies main-horizontal 3
  assert_balanced_rows main-horizontal
}

@test "balance: main-horizontal applies at 5 panes" {
  assert_layout_applies main-horizontal 5
  assert_balanced_rows main-horizontal
}

@test "balance: main-horizontal applies at 7 panes" {
  assert_layout_applies main-horizontal 7
  assert_balanced_rows main-horizontal
}

@test "balance: main-horizontal applies at 9 panes" {
  assert_layout_applies main-horizontal 9
  assert_balanced_rows main-horizontal
}

# ── Main-Center ────────────────────────────────────────────────────

@test "balance: main-center applies at 1 pane" {
  assert_layout_applies main-center 1
}

@test "balance: main-center applies at 2 panes" {
  assert_layout_applies main-center 2
}

@test "balance: main-center applies at 3 panes" {
  assert_layout_applies main-center 3
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 4 panes" {
  assert_layout_applies main-center 4
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 5 panes" {
  assert_layout_applies main-center 5
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 6 panes" {
  assert_layout_applies main-center 6
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 7 panes" {
  assert_layout_applies main-center 7
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 8 panes" {
  assert_layout_applies main-center 8
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 9 panes" {
  assert_layout_applies main-center 9
  assert_balanced_columns main-center
}

@test "balance: main-center applies at 10 panes" {
  assert_layout_applies main-center 10
  assert_balanced_columns main-center
}

# ── Monocle ────────────────────────────────────────────────────────

@test "balance: monocle applies at 1 pane" {
  assert_layout_applies monocle 1
}

@test "balance: monocle applies at 3 panes" {
  assert_layout_applies monocle 3
}

# ── Deck ───────────────────────────────────────────────────────────

@test "balance: deck applies at 1 pane" {
  assert_layout_applies deck 1
}

@test "balance: deck applies at 2 panes" {
  assert_layout_applies deck 2
}

@test "balance: deck applies at 4 panes" {
  assert_layout_applies deck 4
}

@test "balance: deck applies at 6 panes" {
  assert_layout_applies deck 6
}
