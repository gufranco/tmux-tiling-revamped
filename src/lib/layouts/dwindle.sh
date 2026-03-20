#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DWINDLE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DWINDLE_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# _apply_bsp_layout: shared BSP implementation for dwindle and spiral.
#
# Algorithm (ported from sunaku's tmux-layout-dwindle):
#   1. Flatten to even-vertical so all panes are stacked vertically.
#   2. Rearrange via move-pane: each pane N moves pane N+1 beside it, with
#      direction determined by the orientation flags and parity of count.
#   3. Resize: binary-halve each branch pane so sizes cascade.
#   4. Restore pane focus.
# All tmux commands are batched in a single invocation to avoid flicker.
#
# is_spiral_arg: "true" forces spiral trajectory regardless of flags.
# flags: orientation string [t|b][l|r][h|v][c|s].  Defaults to stored
#        window option @tiling_revamped_orientation, then to "brvc".
_apply_bsp_layout() {
  local is_spiral_arg="${1:-false}"
  local flags="${2:-}"

  local -a panes
  mapfile -t panes < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && return 0

  if [[ -z "${flags}" ]]; then
    flags=$(get_window_option "@tiling_revamped_orientation" "")
    [[ -z "${flags}" ]] && flags=$(get_tmux_option "@tiling_revamped_default_orientation" "brvc")
  fi

  # Parse orientation flags
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_vertical=true is_spiral=false

  case "${flags}" in
    *t*) corner_tb='+'; spiral_tb='' ;;
    *)   corner_tb='';  spiral_tb='+' ;;
  esac
  case "${flags}" in
    *l*) corner_lr='+'; spiral_lr='' ;;
    *)   corner_lr='';  spiral_lr='+' ;;
  esac
  case "${flags}" in
    *h*) modulo_hv=0; is_vertical=false ;;
    *)   modulo_hv=1; is_vertical=true ;;
  esac
  case "${flags}" in
    *s*) is_spiral=true ;;
    *)   is_spiral=false ;;
  esac

  case "${is_spiral_arg}" in
    true)  is_spiral=true ;;
    false) is_spiral=false ;;
  esac

  local selected_pane
  selected_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo "")

  local historic_pane=""
  historic_pane=$(tmux last-pane 2>/dev/null \
    && tmux display-message -p '#{pane_id}' 2>/dev/null \
    && tmux last-pane 2>/dev/null) || true

  local window_height
  window_height=$(tmux display-message -p '#{window_height}' 2>/dev/null || echo "24")

  trap 'set_applying 0' RETURN
  set_applying 1

  # shellcheck disable=SC2046
  tmux $(
    {
      echo "select-layout even-vertical"

      # Rearrangement pass: move each pane beside the previous one
      local count=1
      for pane_id in "${panes[@]}"; do
        if (( count == pane_count )); then
          break
        fi

        local move_h='' move_b=''
        if (( count % 2 == modulo_hv )); then
          move_h='+'
          if ${is_spiral} && (( count % 5 > 2 )); then
            move_b="${spiral_lr}"
          else
            move_b="${corner_lr}"
          fi
        else
          move_h=''
          if ${is_spiral} && (( count % 5 > 2 )); then
            move_b="${spiral_tb}"
          else
            move_b="${corner_tb}"
          fi
        fi

        echo "resize-pane -t ${pane_id} -y ${window_height}"
        echo "select-pane -t ${pane_id}"
        local move_cmd="move-pane -d -s .+1 -t ."
        [[ -n "${move_h}" ]] && move_cmd="${move_cmd} -h"
        [[ -n "${move_b}" ]] && move_cmd="${move_cmd} -b"
        echo "${move_cmd}"
        (( count++ ))
      done

      # Sizing pass: binary-halve each branch so sizes cascade
      local branch_height="${window_height}"
      count=1
      for pane_id in "${panes[@]}"; do
        if (( count == pane_count )) && ! ${is_vertical}; then
          break
        fi
        if (( count % 2 == 1 )); then
          local parent_height="${branch_height}"
          (( branch_height = branch_height / 2 ))
          local resize_y
          if ${is_vertical}; then
            resize_y="${parent_height}"
          else
            resize_y="${branch_height}"
          fi
          echo "resize-pane -t ${pane_id} -y ${resize_y}"
        fi
        (( count++ ))
      done

      # Restore focus
      [[ -n "${historic_pane}" ]] && echo "select-pane -t ${historic_pane}"
      [[ -n "${selected_pane}" ]] && echo "select-pane -t ${selected_pane}"
    } | sed 's/$/ ;/'
  ) 2>/dev/null || true
}

apply_layout_dwindle() {
  local flags="${1:-}"
  _apply_bsp_layout "false" "${flags}"
  set_current_layout "dwindle"

  # Normalize flags: ensure 'c' trajectory (corner, not spiral)
  local stored_flags="${flags:-$(get_window_option "@tiling_revamped_orientation" "brvc")}"
  case "${stored_flags}" in
    *c*) ;;
    *s*) stored_flags="${stored_flags//s/c}" ;;
    *)   stored_flags="${stored_flags}c" ;;
  esac
  set_window_option "@tiling_revamped_orientation" "${stored_flags}"
}

export -f _apply_bsp_layout
export -f apply_layout_dwindle
