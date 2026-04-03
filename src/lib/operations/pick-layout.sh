#!/usr/bin/env bash
#
# pick-layout.sh: Interactive fzf-based layout picker for tmux-tiling-revamped.
#
# Requirements:
#   - fzf >= 0.44.0 (for --tmux flag support)
#   - fzf >= 0.19.0 (for --preview flag support)
#
# Features:
#   - ASCII diagram preview for each layout
#   - Logical grouping: BSP layouts first, then standard, main, special
#   - Graceful cancellation on Escape (exit code 130)
#   - Configurable popup dimensions via @tiling_revamped_pick_width/height

[[ -n "${_TILING_REVAMPED_PICK_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PICK_LAYOUT_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/constants.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/layouts/dwindle.sh"
source "${LIB_DIR}/layouts/grid.sh"
source "${LIB_DIR}/layouts/main-center.sh"
source "${LIB_DIR}/layouts/main-vertical.sh"
source "${LIB_DIR}/layouts/main-horizontal.sh"
source "${LIB_DIR}/layouts/monocle.sh"
source "${LIB_DIR}/layouts/deck.sh"

# Logical grouping: BSP layouts first, then standard, main, special layouts
readonly PICK_LAYOUTS=(
  "dwindle"
  "spiral"
  "grid"
  "main-vertical"
  "main-horizontal"
  "main-center"
  "monocle"
  "deck"
)

# _fzf_supports_preview: Check if fzf supports the --preview flag (>= 0.19.0)
_fzf_supports_preview() {
  local fzf_version
  fzf_version=$(fzf --version 2>/dev/null | cut -d' ' -f1)
  [[ -z "$fzf_version" ]] && return 1
  printf '%s\n%s\n' "0.19.0" "$fzf_version" | sort -V -C 2>/dev/null
}

# _get_layout_list: Generate layout list
_get_layout_list() {
  printf '%s\n' "${PICK_LAYOUTS[@]}"
}

# _pick_with_fzf_tmux: Use fzf's native --tmux popup
_pick_with_fzf_tmux() {
  local width height preview_width
  width=$(get_tmux_option "@tiling_revamped_pick_width" "${TILING_DEFAULT_PICK_WIDTH}")
  height=$(get_tmux_option "@tiling_revamped_pick_height" "${TILING_DEFAULT_PICK_HEIGHT}")
  preview_width=$(get_tmux_option "@tiling_revamped_pick_preview_width" "${TILING_DEFAULT_PICK_PREVIEW_WIDTH}")

  # Check if fzf supports preview
  if ! _fzf_supports_preview; then
    log_error "pick-layout" "fzf >= 0.19.0 required for preview support"
    return 1
  fi

  local preview_dir="${LIB_DIR}/operations/layout-previews"

  local selected
  # Use bash -c with $1 to properly handle fzf's {} placeholder
  selected=$(_get_layout_list | fzf --tmux "center,${width},${height}" \
    --prompt="Select layout: " \
    --exit-0 \
    --preview="bash -c 'cat \"${preview_dir}/\$1.txt\"' -- {}" \
    --preview-window="right:${preview_width}" 2>/dev/null)

  local exit_code=$?
  [[ $exit_code -eq 130 ]] && return 130  # User cancelled
  [[ $exit_code -ne 0 ]] && return 1       # Other error

  echo "$selected"
}

# pick_layout: Main entry point - shows fzf picker and applies selected layout
pick_layout() {
  if ! has_command fzf; then
    log_error "pick-layout" "fzf is not installed"
    return 1
  fi

  local selected
  local pick_exit_code=0

  selected=$(_pick_with_fzf_tmux)
  pick_exit_code=$?

  # Graceful cancellation on Escape or empty selection
  [[ $pick_exit_code -eq 130 ]] && return 0
  [[ -z "$selected" ]] && return 0

  # Extract layout name
  local layout_name="$selected"

  # Get current orientation flags for BSP layouts
  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  # Apply selected layout
  case "$layout_name" in
    dwindle)
      _apply_bsp_layout "false" "$flags"
      set_current_layout "dwindle"
      ;;
    spiral)
      _apply_bsp_layout "true" "$flags"
      set_current_layout "spiral"
      ;;
    grid)
      apply_layout_grid
      ;;
    main-vertical)
      apply_layout_main_vertical
      ;;
    main-horizontal)
      apply_layout_main_horizontal
      ;;
    main-center)
      apply_layout_main_center
      ;;
    monocle)
      apply_layout_monocle
      ;;
    deck)
      apply_layout_deck
      ;;
    *)
      log_error "pick-layout" "Unknown layout: $layout_name"
      return 1
      ;;
  esac
}

export -f pick_layout
