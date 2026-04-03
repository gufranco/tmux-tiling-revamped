#!/usr/bin/env bash
#
# tmux-tiling-revamped.tmux: TPM entry point.
#
# Responsibilities:
#   1. Register default keybindings (all configurable via @tiling_revamped_key_*).
#   2. Register hooks for auto-reapplication (when @tiling_revamped_auto_apply=1).
#   3. Register focus-resize hook (when @tiling_revamped_focus_resize=1).
#
# Library sourcing and layout application happen in src/tiling.sh, which is
# invoked on-demand by run-shell.  This keeps startup fast.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TILING_CMD="${PLUGIN_DIR}/src/tiling.sh"

# Minimum bash version: 4.0 (required for associative arrays, ${var^^}, etc.)
_check_bash_version() {
  if (( BASH_VERSINFO[0] < 4 )); then
    tmux display-message "tmux-tiling-revamped: bash 4.0+ required (found ${BASH_VERSION})" 2>/dev/null
    return 1
  fi
  return 0
}

# Minimum tmux version: 3.2 (required for display-popup, hooks with priority)
_check_tmux_version() {
  local tmux_version
  tmux_version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  [[ -z "${tmux_version}" ]] && return 0

  local major="${tmux_version%%.*}"
  local minor="${tmux_version#*.}"
  minor="${minor%%[a-z]*}"
  minor="${minor%%.*}"

  if (( major < 3 )) || { (( major == 3 )) && (( minor < 2 )); }; then
    tmux display-message "tmux-tiling-revamped: tmux 3.2+ required (found ${tmux_version})" 2>/dev/null
    return 1
  fi
  return 0
}

_get_option() {
  local value
  value="$(tmux show-option -gqv "${1}" 2>/dev/null)"
  if [[ -n "${value}" ]]; then
    echo "${value}"
  else
    echo "${2:-}"
  fi
}

_bind() {
  local alt_keys="${1}" key="${2}" cmd="${3}"
  if [[ "${alt_keys}" == "1" ]]; then
    tmux bind-key -n "M-${key}" run-shell "${cmd}"
  else
    tmux bind-key "${key}" run-shell "${cmd}"
  fi
}

_setup_keybindings() {
  local alt_keys
  alt_keys=$(_get_option "@tiling_revamped_alt_keys" "0")

  local key_dwindle;        key_dwindle=$(       _get_option "@tiling_revamped_key_dwindle"         "d")
  local key_spiral;         key_spiral=$(        _get_option "@tiling_revamped_key_spiral"          "D")
  local key_balance;        key_balance=$(       _get_option "@tiling_revamped_key_balance"         "b")
  local key_equalize;       key_equalize=$(      _get_option "@tiling_revamped_key_equalize"        "B")
  local key_promote;        key_promote=$(       _get_option "@tiling_revamped_key_promote"         "m")
  local key_rotate;         key_rotate=$(        _get_option "@tiling_revamped_key_rotate"          ".")
  local key_flip;           key_flip=$(          _get_option "@tiling_revamped_key_flip"            ",")
  local key_circulate;      key_circulate=$(     _get_option "@tiling_revamped_key_circulate"       "C-r")
  local key_autotile;       key_autotile=$(      _get_option "@tiling_revamped_key_autotile"        "C-d")
  local key_cycle;          key_cycle=$(         _get_option "@tiling_revamped_key_cycle"           "o")
  local key_mark;           key_mark=$(          _get_option "@tiling_revamped_key_mark"            "M")
  local key_jump;           key_jump=$(          _get_option "@tiling_revamped_key_jump"            "j")
  local key_scratchpad;     key_scratchpad=$(    _get_option "@tiling_revamped_key_scratchpad"      "g")
  local key_main_vertical;  key_main_vertical=$( _get_option "@tiling_revamped_key_main_vertical"   "v")
  local key_main_horizontal;key_main_horizontal=$(_get_option "@tiling_revamped_key_main_horizontal" "V")
  local key_master_grow;    key_master_grow=$(   _get_option "@tiling_revamped_key_master_grow"     "+")
  local key_master_shrink;  key_master_shrink=$( _get_option "@tiling_revamped_key_master_shrink"   "-")
  local key_sync;           key_sync=$(          _get_option "@tiling_revamped_key_sync"            "S")
  local key_swap_up;        key_swap_up=$(       _get_option "@tiling_revamped_key_swap_up"         "")
  local key_swap_down;      key_swap_down=$(     _get_option "@tiling_revamped_key_swap_down"       "")
  local key_swap_left;      key_swap_left=$(     _get_option "@tiling_revamped_key_swap_left"       "")
  local key_swap_right;     key_swap_right=$(    _get_option "@tiling_revamped_key_swap_right"      "")
  local key_pick_layout;    key_pick_layout=$(   _get_option "@tiling_revamped_key_pick_layout"    "p")

  _bind "${alt_keys}" "${key_dwindle}"        "${TILING_CMD} layout dwindle"
  _bind "${alt_keys}" "${key_spiral}"         "${TILING_CMD} layout spiral"
  _bind "${alt_keys}" "${key_balance}"        "${TILING_CMD} balance"
  _bind "${alt_keys}" "${key_equalize}"       "${TILING_CMD} equalize"
  _bind "${alt_keys}" "${key_promote}"        "${TILING_CMD} promote"
  _bind "${alt_keys}" "${key_rotate}"         "${TILING_CMD} rotate"
  _bind "${alt_keys}" "${key_flip}"           "${TILING_CMD} flip"
  _bind "${alt_keys}" "${key_circulate}"      "${TILING_CMD} circulate"
  _bind "${alt_keys}" "${key_autotile}"       "${TILING_CMD} autosplit"
  _bind "${alt_keys}" "${key_cycle}"          "${TILING_CMD} cycle"
  _bind "${alt_keys}" "${key_main_vertical}"  "${TILING_CMD} layout main-vertical"
  _bind "${alt_keys}" "${key_main_horizontal}" "${TILING_CMD} layout main-horizontal"
  _bind "${alt_keys}" "${key_master_grow}"    "${TILING_CMD} resize-master grow"
  _bind "${alt_keys}" "${key_master_shrink}"  "${TILING_CMD} resize-master shrink"
  _bind "${alt_keys}" "${key_sync}"           "${TILING_CMD} sync"

  # Mark uses command-prompt, so always prefix-based
  tmux bind-key "${key_mark}" command-prompt \
    -p "Mark name:" "run-shell '${TILING_CMD} mark %%'"
  _bind "${alt_keys}" "${key_jump}" "${TILING_CMD} jump"
  _bind "${alt_keys}" "${key_scratchpad}" "${TILING_CMD} scratchpad"

  # Directional swap bindings (empty key = disabled)
  [[ -n "${key_swap_up}" ]]    && _bind "${alt_keys}" "${key_swap_up}"    "${TILING_CMD} swap U"
  [[ -n "${key_swap_down}" ]]  && _bind "${alt_keys}" "${key_swap_down}"  "${TILING_CMD} swap D"
  [[ -n "${key_swap_left}" ]]  && _bind "${alt_keys}" "${key_swap_left}"  "${TILING_CMD} swap L"
  [[ -n "${key_swap_right}" ]] && _bind "${alt_keys}" "${key_swap_right}" "${TILING_CMD} swap R"

  # Layout picker binding (empty key = disabled)
  [[ -n "${key_pick_layout}" ]] && _bind "${alt_keys}" "${key_pick_layout}" "${TILING_CMD} pick"
}

_setup_hooks() {
  # Clear previous tiling hooks to prevent accumulation on config reload
  tmux set-hook -gu "after-split-window[100]" 2>/dev/null || true
  tmux set-hook -gu "after-kill-pane[100]" 2>/dev/null || true
  tmux set-hook -gu "pane-exited[100]" 2>/dev/null || true
  tmux set-hook -gu "window-resized[100]" 2>/dev/null || true
  tmux set-hook -gu "after-new-window[100]" 2>/dev/null || true
  tmux set-hook -gu "pane-focus-in[100]" 2>/dev/null || true

  local auto_apply
  auto_apply=$(_get_option "@tiling_revamped_auto_apply" "1")

  if [[ "${auto_apply}" == "1" ]]; then
    tmux set-hook -ga "after-split-window[100]" \
      "run-shell '${TILING_CMD} hook split'"
    tmux set-hook -ga "after-kill-pane[100]" \
      "run-shell '${TILING_CMD} hook kill'"
    tmux set-hook -ga "pane-exited[100]" \
      "run-shell '${TILING_CMD} hook exit'"
    tmux set-hook -ga "window-resized[100]" \
      "run-shell '${TILING_CMD} hook resize'"
  fi

  # Default layout for new windows
  local default_layout
  default_layout=$(_get_option "@tiling_revamped_default_layout" "")
  if [[ -n "${default_layout}" ]]; then
    tmux set-hook -ga "after-new-window[100]" \
      "run-shell '${TILING_CMD} hook new-window'"
  fi

  local focus_resize
  focus_resize=$(_get_option "@tiling_revamped_focus_resize" "0")

  if [[ "${focus_resize}" == "1" ]]; then
    tmux set-hook -ga "pane-focus-in[100]" \
      "run-shell '${TILING_CMD} focus-resize'"
  fi
}

_setup_navigation() {
  local navigator
  navigator=$(_get_option "@tiling_revamped_navigator" "0")

  [[ "${navigator}" != "1" ]] && return 0

  local is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"

  tmux bind-key -n M-h if-shell "${is_vim}" "send-keys M-h" "select-pane -L"
  tmux bind-key -n M-j if-shell "${is_vim}" "send-keys M-j" "select-pane -D"
  tmux bind-key -n M-k if-shell "${is_vim}" "send-keys M-k" "select-pane -U"
  tmux bind-key -n M-l if-shell "${is_vim}" "send-keys M-l" "select-pane -R"
}

_setup_pick_layout_binding() {
  local key_pick_layout_alt
  key_pick_layout_alt=$(_get_option "@tiling_revamped_key_pick_layout_alt" "")

  [[ -z "${key_pick_layout_alt}" ]] && return 0

  # Vim detection pattern (same as navigator)
  local is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"

  # Generate vim-aware Alt binding
  tmux bind-key -n "M-${key_pick_layout_alt}" \
    if-shell "${is_vim}" \
    "send-keys M-${key_pick_layout_alt}" \
    "run-shell '${TILING_CMD} pick'"
}

chmod +x "${TILING_CMD}" 2>/dev/null || true

_check_bash_version || return 0
_check_tmux_version || return 0

_setup_keybindings
_setup_hooks
_setup_navigation
_setup_pick_layout_binding
