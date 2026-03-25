#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_CIRCULATE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_CIRCULATE_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# circulate_panes: shift all pane positions by one step.
#
# next - tmux rotate-window -U: last pane becomes first  (counter-clockwise)
# prev - tmux rotate-window -D: first pane becomes last  (clockwise)
#
# After rotating positions, the current layout is re-applied so that the
# new arrangement uses the correct sizes for each slot.
circulate_panes() {
  local direction="${1:-next}"
  local pane_count
  pane_count=$(get_pane_count)

  (( pane_count <= 1 )) && return 0

  local selected_pane
  selected_pane=$(get_current_pane)

  if [[ "${direction}" == "prev" ]]; then
    tmux rotate-window -D 2>/dev/null || true
  else
    tmux rotate-window -U 2>/dev/null || true
  fi

  local current_layout
  current_layout=$(get_current_layout)
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

  # Restore focus to the same pane (it may have moved slots)
  tmux select-pane -t "${selected_pane}" 2>/dev/null || true
}

export -f circulate_panes
