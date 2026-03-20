#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_GRID_LOADED:-}" ]] && return 0
_TILING_REVAMPED_GRID_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# Grid layout: even N×M grid.  Uses tmux's built-in "tiled" layout which
# distributes panes into the smallest rectangle that fits all of them.
apply_layout_grid() {
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && { set_current_layout "grid"; return 0; }

  set_applying 1
  tmux select-layout tiled 2>/dev/null || true
  set_applying 0
  set_current_layout "grid"
}

export -f apply_layout_grid
