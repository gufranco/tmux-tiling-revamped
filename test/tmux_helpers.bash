#!/usr/bin/env bash
#
# Integration test helpers for tmux-tiling-revamped.
#
# Manages a real tmux server per test via a unique socket.
# Layout and integration tests source this file instead of helpers.bash.

PLUGIN_DIR="${BATS_TEST_DIRNAME}"
while [[ "${PLUGIN_DIR}" != "/" ]] && [[ ! -f "${PLUGIN_DIR}/tmux-tiling-revamped.tmux" ]]; do
  PLUGIN_DIR="$(dirname "${PLUGIN_DIR}")"
done

TILING_CMD="${PLUGIN_DIR}/src/tiling.sh"
TMUX_SOCKET="/tmp/tiling-test-${BASHPID}-${RANDOM}"

setup_tmux_server() {
  # Start a detached tmux server with deterministic dimensions
  command tmux -S "${TMUX_SOCKET}" new-session -d -s test -x 200 -y 50 2>/dev/null
  # Give the server a moment to initialize
  sleep 0.1
}

teardown_tmux_server() {
  command tmux -S "${TMUX_SOCKET}" kill-server 2>/dev/null || true
  rm -f "${TMUX_SOCKET}" 2>/dev/null || true
}

# Override tmux so all calls within the test use the test socket.
# The real tmux binary is reached via `command tmux`.
tmux() {
  command tmux -S "${TMUX_SOCKET}" "$@"
}

create_panes() {
  local count="${1:-3}"
  local i
  for (( i=1; i<count; i++ )); do
    command tmux -S "${TMUX_SOCKET}" split-window -d 2>/dev/null
  done
  # Let panes settle
  sleep 0.1
}

get_pane_count() {
  command tmux -S "${TMUX_SOCKET}" list-panes 2>/dev/null | wc -l | tr -d ' '
}

get_pane_dimensions() {
  local pane_id="${1:-%0}"
  command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_id}" \
    '#{pane_width}x#{pane_height}' 2>/dev/null || echo "0x0"
}

assert_pane_count() {
  local expected="${1}"
  local actual
  actual=$(get_pane_count)
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected ${expected} panes, got ${actual}" >&2
    return 1
  fi
}

assert_pane_wider_than() {
  local pane_a="${1}"
  local pane_b="${2}"
  local width_a width_b
  width_a=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_a}" \
    '#{pane_width}' 2>/dev/null || echo "0")
  width_b=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_b}" \
    '#{pane_width}' 2>/dev/null || echo "0")
  if (( width_a <= width_b )); then
    echo "Pane ${pane_a} (width=${width_a}) not wider than pane ${pane_b} (width=${width_b})" >&2
    return 1
  fi
}

assert_pane_taller_than() {
  local pane_a="${1}"
  local pane_b="${2}"
  local height_a height_b
  height_a=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_a}" \
    '#{pane_height}' 2>/dev/null || echo "0")
  height_b=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_b}" \
    '#{pane_height}' 2>/dev/null || echo "0")
  if (( height_a <= height_b )); then
    echo "Pane ${pane_a} (height=${height_a}) not taller than pane ${pane_b} (height=${height_b})" >&2
    return 1
  fi
}

run_tiling() {
  command tmux -S "${TMUX_SOCKET}" \
    run-shell "TMUX_SOCKET=${TMUX_SOCKET} bash ${TILING_CMD} $*" 2>/dev/null
  sleep 0.2
}

export -f tmux
export TMUX_SOCKET
export TILING_CMD
export PLUGIN_DIR
