#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_ERROR_LOGGER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_ERROR_LOGGER_LOADED=1

TILING_LOG_DIR="${TILING_LOG_DIR:-${HOME}/.tmux/tiling-logs}"
TILING_LOG_FILE="${TILING_LOG_FILE:-${TILING_LOG_DIR}/tiling.log}"
TILING_MAX_LOG_SIZE="${TILING_MAX_LOG_SIZE:-1048576}"
TILING_MAX_LOG_LINES="${TILING_MAX_LOG_LINES:-1000}"

mkdir -p "${TILING_LOG_DIR}" 2>/dev/null || true

log_error() {
  local component="${1:-unknown}"
  local message="${2:-}"

  [[ -z "${message}" ]] && return 0

  component="${component//[^a-zA-Z0-9_-]/}"

  if [[ "$(tmux show-option -gqv @tiling_revamped_enable_logging 2>/dev/null)" == "1" ]]; then
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "")

    if [[ -n "${timestamp}" ]] && [[ -w "${TILING_LOG_DIR}" ]] 2>/dev/null; then
      echo "[${timestamp}] [${component}] ${message}" >> "${TILING_LOG_FILE}" 2>/dev/null

      if [[ -f "${TILING_LOG_FILE}" ]]; then
        local log_size
        log_size=$(stat -f%z "${TILING_LOG_FILE}" 2>/dev/null \
          || stat -c%s "${TILING_LOG_FILE}" 2>/dev/null \
          || echo "0")
        if [[ -n "${log_size}" ]] && [[ "${log_size}" =~ ^[0-9]+$ ]] \
            && (( log_size > TILING_MAX_LOG_SIZE )); then
          tail -n "${TILING_MAX_LOG_LINES}" "${TILING_LOG_FILE}" \
            > "${TILING_LOG_FILE}.tmp" 2>/dev/null
          mv "${TILING_LOG_FILE}.tmp" "${TILING_LOG_FILE}" 2>/dev/null || true
        fi
      fi
    fi
  fi
}

export -f log_error
