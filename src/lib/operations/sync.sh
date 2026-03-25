#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SYNC_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SYNC_LOADED=1

# sync_panes: toggle synchronize-panes for the current window.
#
# When enabled, all keystrokes are broadcast to every pane in the window.
# Useful for running the same command on multiple servers simultaneously.
sync_panes() {
  tmux set-window-option synchronize-panes 2>/dev/null || true
}

export -f sync_panes
