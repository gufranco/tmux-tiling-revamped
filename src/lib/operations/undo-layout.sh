#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_UNDO_LAYOUT_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

readonly TILING_MAX_UNDO_DEPTH=10

# push_layout_history: save current layout and orientation before a change.
# Stores as a pipe-separated stack: "layout:flags|layout:flags|..."
push_layout_history() {
  local current_layout
  current_layout=$(get_current_layout)
  [[ -z "${current_layout}" ]] && return 0

  local current_flags
  current_flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  local entry="${current_layout}:${current_flags}"

  local history
  history=$(get_window_option "@tiling_revamped_layout_history" "")

  if [[ -n "${history}" ]]; then
    history="${entry}|${history}"
  else
    history="${entry}"
  fi

  # Trim to max depth
  local -a parts
  IFS='|' read -ra parts <<< "${history}"
  if (( ${#parts[@]} > TILING_MAX_UNDO_DEPTH )); then
    local trimmed=""
    local i
    for (( i = 0; i < TILING_MAX_UNDO_DEPTH; i++ )); do
      [[ -n "${trimmed}" ]] && trimmed="${trimmed}|"
      trimmed="${trimmed}${parts[i]}"
    done
    history="${trimmed}"
  fi

  set_window_option "@tiling_revamped_layout_history" "${history}"
}

# undo_layout: pop the most recent layout from history and re-apply it.
undo_layout() {
  local history
  history=$(get_window_option "@tiling_revamped_layout_history" "")

  [[ -z "${history}" ]] && return 0

  # Pop the first entry
  local entry="${history%%|*}"
  local remaining="${history#*|}"
  [[ "${remaining}" == "${history}" ]] && remaining=""

  # Update history with the remaining stack
  set_window_option "@tiling_revamped_layout_history" "${remaining}"

  local layout="${entry%%:*}"
  local flags="${entry#*:}"

  [[ -z "${layout}" ]] && return 0

  # Set orientation flags before applying
  [[ -n "${flags}" ]] && set_window_option "@tiling_revamped_orientation" "${flags}"

  # Apply without pushing to history (would create infinite loop)
  case "${layout}" in
    dwindle)         _apply_bsp_layout "false" "${flags}"; set_current_layout "dwindle" ;;
    spiral)          _apply_bsp_layout "true" "${flags}"; set_current_layout "spiral" ;;
    grid)            apply_layout_grid ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    main-center)     apply_layout_main_center ;;
    monocle)         apply_layout_monocle ;;
    deck)            apply_layout_deck ;;
    *)               return 1 ;;
  esac
}

export -f push_layout_history
export -f undo_layout
