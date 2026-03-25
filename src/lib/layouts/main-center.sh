#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_MAIN_CENTER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_MAIN_CENTER_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# Main-center layout: one wide center pane with narrower side panes.
#
# 1 pane:   [ main ]
# 2 panes:  [ main ][ side ]  (60/40)
# 3 panes:  [ left ][ main ][ right ]  (20/60/20)
# 4+ panes: [ left ][ main ][ right ] where right pane stacks extras
apply_layout_main_center() {
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && { set_current_layout "main-center"; return 0; }

  local selected_pane
  selected_pane=$(get_current_pane)

  local window_width
  window_width=$(get_window_width)

  local main_ratio
  main_ratio=$(get_numeric_option "@tiling_revamped_main_center_ratio" "60" "20" "90")

  local main_width=$(( window_width * main_ratio / 100 ))
  local side_width=$(( (window_width - main_width) / 2 ))

  trap 'set_applying 0' RETURN
  set_applying 1

  # shellcheck disable=SC2046
  tmux $(
    {
      # Start from main-vertical: first pane left, rest stacked right
      echo "select-layout main-vertical"
      echo "resize-pane -t ${panes[0]} -x ${main_width}"

      if (( pane_count >= 3 )); then
        # Move the right-column top pane to become a left column
        echo "select-pane -t ${panes[1]}"
        echo "move-pane -h -b -s ${panes[1]} -t ${panes[0]}"
        echo "resize-pane -t ${panes[1]} -x ${side_width}"
        # Re-resize center after move-pane resets widths
        echo "resize-pane -t ${panes[0]} -x ${main_width}"
      fi

      [[ -n "${selected_pane}" ]] && echo "select-pane -t ${selected_pane}"
    } | sed 's/$/ ;/'
  ) 2>/dev/null || true

  set_current_layout "main-center"
}

export -f apply_layout_main_center
