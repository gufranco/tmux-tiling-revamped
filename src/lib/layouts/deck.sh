#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DECK_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DECK_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# Deck layout: all panes are full-height, stacked horizontally at equal widths.
# Conceptually like a "deck of cards" viewed from the side — every pane is
# reachable but only the focused one is the primary viewport.
apply_layout_deck() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && { set_current_layout "deck"; return 0; }

  trap 'set_applying 0' RETURN
  set_applying 1
  tmux select-layout even-horizontal 2>/dev/null || true
  set_current_layout "deck"
}

TILING_PREVIEW_DECK='Deck Layout (4 panes)
┌───────────┬───────────┬───────────┬───┐
│           │           │           │   │
│           │           │           │   │
│     1     │     2     │     3     │ 4 │
│           │           │           │   │
│           │           │           │   │
└───────────┴───────────┴───────────┴───┘
Full-height cards side by side'
export TILING_PREVIEW_DECK

export -f apply_layout_deck
