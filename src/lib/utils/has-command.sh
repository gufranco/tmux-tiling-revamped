#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_HAS_COMMAND_LOADED:-}" ]] && return 0
_TILING_REVAMPED_HAS_COMMAND_LOADED=1

declare -gA _TILING_COMMAND_CACHE=()

has_command() {
  local cmd="${1}"

  if [[ -n "${_TILING_COMMAND_CACHE[${cmd}]:-}" ]]; then
    [[ "${_TILING_COMMAND_CACHE[${cmd}]}" == "1" ]]
    return
  fi

  if command -v "${cmd}" >/dev/null 2>&1; then
    _TILING_COMMAND_CACHE["${cmd}"]="1"
    return 0
  else
    _TILING_COMMAND_CACHE["${cmd}"]="0"
    return 1
  fi
}

export -f has_command
