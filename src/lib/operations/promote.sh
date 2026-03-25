#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PROMOTE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PROMOTE_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# promote_pane: swap the focused pane with the master (first) pane.
# If the focused pane is already master, demote it to position 2 (dwm-style).
# After swapping, the current layout is re-applied so sizes are preserved.
promote_pane() {
  local -a panes
  mapfile -t panes < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && return 0

  local current_pane
  current_pane=$(get_current_pane)

  local master_pane="${panes[0]}"

  if [[ "${current_pane}" == "${master_pane}" ]]; then
    # Focused pane is already master: demote to position 2
    if (( pane_count > 1 )); then
      tmux swap-pane -s "${panes[0]}" -t "${panes[1]}" 2>/dev/null || true
    fi
  else
    tmux swap-pane -s "${current_pane}" -t "${master_pane}" 2>/dev/null || true
  fi

  # Re-apply layout so sizes recalculate around the new master
  local current_layout
  current_layout=$(get_current_layout)

  if [[ -n "${current_layout}" ]]; then
    local flags
    flags=$(get_window_option "@tiling_revamped_orientation" "brvc")
    case "${current_layout}" in
      dwindle) _apply_bsp_layout "false" "${flags}" ;;
      spiral)  _apply_bsp_layout "true"  "${flags}" ;;
      grid)
        set_applying 1
        tmux select-layout tiled 2>/dev/null || true
        set_applying 0
        ;;
      deck)
        set_applying 1
        tmux select-layout even-horizontal 2>/dev/null || true
        set_applying 0
        ;;
      main-vertical)   apply_layout_main_vertical ;;
      main-horizontal) apply_layout_main_horizontal ;;
      main-center)     apply_layout_main_center ;;
      *)       ;;
    esac
  fi
}

export -f promote_pane
