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

_get_option() {
  tmux show-option -gqv "${1}" 2>/dev/null || echo "${2:-}"
}

_setup_keybindings() {
  local key_dwindle;   key_dwindle=$(  _get_option "@tiling_revamped_key_dwindle"   "d")
  local key_spiral;    key_spiral=$(   _get_option "@tiling_revamped_key_spiral"    "D")
  local key_balance;   key_balance=$(  _get_option "@tiling_revamped_key_balance"   "b")
  local key_equalize;  key_equalize=$( _get_option "@tiling_revamped_key_equalize"  "B")
  local key_promote;   key_promote=$(  _get_option "@tiling_revamped_key_promote"   "m")
  local key_rotate;    key_rotate=$(   _get_option "@tiling_revamped_key_rotate"    ".")
  local key_flip;      key_flip=$(     _get_option "@tiling_revamped_key_flip"      ",")
  local key_circulate; key_circulate=$(_get_option "@tiling_revamped_key_circulate" "C-r")
  local key_autotile;  key_autotile=$( _get_option "@tiling_revamped_key_autotile"  "C-d")
  local key_cycle;     key_cycle=$(    _get_option "@tiling_revamped_key_cycle"     "o")
  local key_mark;      key_mark=$(     _get_option "@tiling_revamped_key_mark"      "M")
  local key_jump;      key_jump=$(     _get_option "@tiling_revamped_key_jump"      "j")
  local key_scratchpad;key_scratchpad=$(_get_option "@tiling_revamped_key_scratchpad" "g")

  tmux bind-key "${key_dwindle}"   run-shell "${TILING_CMD} layout dwindle"
  tmux bind-key "${key_spiral}"    run-shell "${TILING_CMD} layout spiral"
  tmux bind-key "${key_balance}"   run-shell "${TILING_CMD} balance"
  tmux bind-key "${key_equalize}"  run-shell "${TILING_CMD} equalize"
  tmux bind-key "${key_promote}"   run-shell "${TILING_CMD} promote"
  tmux bind-key "${key_rotate}"    run-shell "${TILING_CMD} rotate"
  tmux bind-key "${key_flip}"      run-shell "${TILING_CMD} flip"
  tmux bind-key "${key_circulate}" run-shell "${TILING_CMD} circulate"
  tmux bind-key "${key_autotile}"  run-shell "${TILING_CMD} autosplit"
  tmux bind-key "${key_cycle}"     run-shell "${TILING_CMD} cycle"
  tmux bind-key "${key_mark}"      command-prompt \
    -p "Mark name:" "run-shell '${TILING_CMD} mark %%'"
  tmux bind-key "${key_jump}"      run-shell "${TILING_CMD} jump"
  tmux bind-key "${key_scratchpad}" run-shell "${TILING_CMD} scratchpad"
}

_setup_hooks() {
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

  local focus_resize
  focus_resize=$(_get_option "@tiling_revamped_focus_resize" "0")

  if [[ "${focus_resize}" == "1" ]]; then
    tmux set-hook -ga "pane-focus-in[100]" \
      "run-shell '${TILING_CMD} focus-resize'"
  fi
}

chmod +x "${TILING_CMD}" 2>/dev/null || true

_setup_keybindings
_setup_hooks
