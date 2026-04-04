#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PANE_GUARD_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PANE_GUARD_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"

readonly TILING_DEFAULT_MIN_PANE_WIDTH=10
readonly TILING_DEFAULT_MIN_PANE_HEIGHT=5

# check_pane_size: verify that panes will not shrink below minimum dimensions.
# Args: pane_count window_width window_height layout
# Returns 0 if safe, 1 if panes would be too small.
check_pane_size() {
  local pane_count="${1}"
  local window_width="${2}"
  local window_height="${3}"
  local layout="${4:-}"

  local min_width
  min_width=$(get_tmux_option "@tiling_revamped_min_pane_width" "${TILING_DEFAULT_MIN_PANE_WIDTH}")
  local min_height
  min_height=$(get_tmux_option "@tiling_revamped_min_pane_height" "${TILING_DEFAULT_MIN_PANE_HEIGHT}")

  (( pane_count <= 1 )) && return 0

  # Estimate smallest pane dimension based on layout type
  local est_width est_height

  case "${layout}" in
    grid)
      # Grid: sqrt(N) columns and rows
      local cols=$(( pane_count > 4 ? 3 : 2 ))
      local rows=$(( (pane_count + cols - 1) / cols ))
      est_width=$(( (window_width - cols + 1) / cols ))
      est_height=$(( (window_height - rows + 1) / rows ))
      ;;
    deck)
      est_width=$(( (window_width - pane_count + 1) / pane_count ))
      est_height="${window_height}"
      ;;
    main-vertical)
      local stack=$(( pane_count - 1 ))
      est_width=$(( window_width * 40 / 100 ))
      est_height=$(( (window_height - stack + 1) / stack ))
      ;;
    main-horizontal)
      local stack=$(( pane_count - 1 ))
      est_width=$(( (window_width - stack + 1) / stack ))
      est_height=$(( window_height * 40 / 100 ))
      ;;
    main-center)
      local side=$(( (pane_count - 1 + 1) / 2 ))
      (( side < 1 )) && side=1
      est_width=$(( window_width * 20 / 100 ))
      est_height=$(( (window_height - side + 1) / side ))
      ;;
    dwindle|spiral)
      # BSP: deepest pane is approximately window / 2^(depth/2)
      local depth=$(( pane_count - 1 ))
      local halvings=$(( (depth + 1) / 2 ))
      est_width=$(( window_width >> halvings ))
      est_height=$(( window_height >> halvings ))
      ;;
    *)
      return 0
      ;;
  esac

  if (( est_width < min_width )) || (( est_height < min_height )); then
    log_error "pane-guard" "Too many panes for ${layout}: estimated ${est_width}x${est_height}, minimum ${min_width}x${min_height}"
    return 1
  fi

  return 0
}

export -f check_pane_size
