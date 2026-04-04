#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_WORKSPACES_LOADED:-}" ]] && return 0
_TILING_REVAMPED_WORKSPACES_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

# switch_workspace: switch to window N, creating it if it does not exist.
switch_workspace() {
  local target="${1:-1}"

  if ! [[ "${target}" =~ ^[0-9]+$ ]]; then
    log_error "workspaces" "Invalid workspace number: ${target}"
    return 1
  fi

  # Check if window exists
  if tmux select-window -t ":${target}" 2>/dev/null; then
    return 0
  fi

  # Window does not exist, create it
  tmux new-window -t ":${target}" 2>/dev/null || return 1
}

# move_to_workspace: move the current pane to window N.
# Creates the target window if it does not exist.
# If the current window becomes empty after the move, it is removed.
move_to_workspace() {
  local target="${1:-1}"

  if ! [[ "${target}" =~ ^[0-9]+$ ]]; then
    log_error "workspaces" "Invalid workspace number: ${target}"
    return 1
  fi

  local current_pane
  current_pane=$(get_current_pane)
  [[ -z "${current_pane}" ]] && return 1

  # Ensure target window exists
  if ! tmux select-window -t ":${target}" 2>/dev/null; then
    tmux new-window -d -t ":${target}" 2>/dev/null || return 1
  fi

  # Join the pane to the target window
  tmux join-pane -t ":${target}" -s "${current_pane}" 2>/dev/null || return 1

  # Switch to the target window
  tmux select-window -t ":${target}" 2>/dev/null || true
}

export -f switch_workspace
export -f move_to_workspace
