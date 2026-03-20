#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_TMUX_CONFIG_LOADED:-}" ]] && return 0
_TILING_REVAMPED_TMUX_CONFIG_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-ops.sh"

is_option_enabled() {
  local value
  value=$(get_tmux_option "${1}" "0")
  [[ "${value}" == "1" || "${value}" == "true" ]]
}

is_window_option_enabled() {
  local value
  value=$(get_window_option "${1}" "0")
  [[ "${value}" == "1" || "${value}" == "true" ]]
}

get_numeric_option() {
  local value
  value=$(get_tmux_option "${1}" "${2}")

  if ! [[ "${value}" =~ ^[0-9]+$ ]]; then
    echo "${2}"
    return
  fi

  local min="${3:-0}"
  local max="${4:-999999}"

  (( value < min )) && echo "${min}" && return
  (( value > max )) && echo "${max}" && return
  echo "${value}"
}

get_current_layout() {
  get_window_option "@tiling_revamped_layout" ""
}

set_current_layout() {
  set_window_option "@tiling_revamped_layout" "${1}"
}

is_auto_apply_enabled() {
  local window_val
  window_val=$(get_window_option "@tiling_revamped_enabled" "")
  if [[ -n "${window_val}" ]]; then
    [[ "${window_val}" == "1" ]]
    return
  fi
  is_option_enabled "@tiling_revamped_auto_apply"
}

is_applying() {
  [[ "$(get_tmux_option "@tiling_revamped_applying" "0")" == "1" ]]
}

set_applying() {
  set_tmux_option "@tiling_revamped_applying" "${1:-1}"
}

export -f is_option_enabled
export -f is_window_option_enabled
export -f get_numeric_option
export -f get_current_layout
export -f set_current_layout
export -f is_auto_apply_enabled
export -f is_applying
export -f set_applying
