#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_RESURRECT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_RESURRECT_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# restore_layouts: re-apply stored layouts to all windows.
# Called after tmux-resurrect restores a session. Each window that has
# a stored @tiling_revamped_layout option gets its layout re-applied.
restore_layouts() {
  local -a windows
  while IFS= read -r win; do
    windows+=("${win}")
  done < <(tmux list-windows -F '#{window_id}' 2>/dev/null)

  local win layout flags
  for win in "${windows[@]}"; do
    layout=$(tmux show-option -wqv -t "${win}" "@tiling_revamped_layout" 2>/dev/null)
    [[ -z "${layout}" ]] && continue

    flags=$(tmux show-option -wqv -t "${win}" "@tiling_revamped_orientation" 2>/dev/null)
    [[ -z "${flags}" ]] && flags="brvc"

    # Select the window and re-apply its layout
    tmux select-window -t "${win}" 2>/dev/null || continue

    case "${layout}" in
      dwindle)         _apply_bsp_layout "false" "${flags}" ;;
      spiral)          _apply_bsp_layout "true" "${flags}" ;;
      grid)            apply_layout_grid ;;
      main-vertical)   apply_layout_main_vertical ;;
      main-horizontal) apply_layout_main_horizontal ;;
      main-center)     apply_layout_main_center ;;
      deck)            apply_layout_deck ;;
      monocle)         ;; # Zoom state is not restorable
    esac
  done
}

export -f restore_layouts
