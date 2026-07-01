#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_HELP_OVERLAY_LOADED:-}" ]] && return 0
_TILING_REVAMPED_HELP_OVERLAY_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# _help_lines: render one "key  action" row per binding, using resolved keys.
# The action table lives in the heredoc below as data, not code, so kcov does
# not count each row as an executable line. The resolved key is the user's
# @tiling_revamped_key_* value when set, otherwise the default, so this renders
# what is actually bound. A binding whose key resolves to empty is omitted.
_help_lines() {
  local label option default key
  while IFS='|' read -r label option default; do
    [[ -z "${label}" ]] && continue
    key=$(get_tmux_option "${option}" "${default}")
    [[ -z "${key}" ]] && continue
    printf '%-7s %s\n' "${key}" "${label}"
  done <<'ACTIONS'
Dwindle layout|@tiling_revamped_key_dwindle|d
Spiral layout|@tiling_revamped_key_spiral|D
Main-vertical layout|@tiling_revamped_key_main_vertical|v
Main-horizontal layout|@tiling_revamped_key_main_horizontal|V
Balance panes|@tiling_revamped_key_balance|b
Equalize panes|@tiling_revamped_key_equalize|B
Promote to master|@tiling_revamped_key_promote|m
Rotate layout|@tiling_revamped_key_rotate|.
Flip layout|@tiling_revamped_key_flip|,
Circulate panes|@tiling_revamped_key_circulate|C-r
Autosplit|@tiling_revamped_key_autotile|C-d
Cycle layout|@tiling_revamped_key_cycle|o
Grow master|@tiling_revamped_key_master_grow|+
Shrink master|@tiling_revamped_key_master_shrink|-
Toggle sync|@tiling_revamped_key_sync|S
Mark pane|@tiling_revamped_key_mark|M
Jump to mark|@tiling_revamped_key_jump|j
Scratchpad|@tiling_revamped_key_scratchpad|g
Layout picker|@tiling_revamped_key_pick_layout|p
Swap with biggest|@tiling_revamped_key_swap_biggest|=
Undo layout|@tiling_revamped_key_undo|u
Redo layout|@tiling_revamped_key_redo|r
ACTIONS
}

# _popup_supported: true when tmux is new enough for display-popup (3.2+).
_popup_supported() {
  local version major minor
  version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  [[ -z "${version}" ]] && return 1

  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%[a-z]*}"
  minor="${minor%%.*}"
  [[ "${minor}" =~ ^[0-9]+$ ]] || minor=0

  if (( major > 3 )); then
    return 0
  fi
  if (( major == 3 )) && (( minor >= 2 )); then
    return 0
  fi
  return 1
}

# show_help: render the resolved keybindings in a display-popup. On tmux older
# than 3.2 the popup is unavailable, so fall back to a status message.
show_help() {
  if ! _popup_supported; then
    tmux display-message "tmux-tiling-revamped: help overlay needs tmux 3.2+" 2>/dev/null
    return 0
  fi

  local width height
  width=$(get_tmux_option "@tiling_revamped_help_width" "50%")
  height=$(get_tmux_option "@tiling_revamped_help_height" "60%")

  local body
  body=$(_help_lines)

  local escaped="${body//\'/\'\\\'\'}"
  local popup_cmd
  popup_cmd="printf '%s\n' 'tmux-tiling-revamped keybindings'; printf '%s\n' '${escaped}'; printf '\nPress any key to close\n'; read -r _"

  tmux display-popup -E -w "${width}" -h "${height}" "${popup_cmd}" 2>/dev/null || true
}

export -f _help_lines
export -f _popup_supported
export -f show_help
