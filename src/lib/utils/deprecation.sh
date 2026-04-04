#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DEPRECATION_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DEPRECATION_LOADED=1

# _check_deprecated_options: warn about deprecated tmux options.
# Each entry maps an old option name to its replacement.
# Deprecated options are checked on plugin load and logged if found.
_check_deprecated_options() {
  # Format: "old_option|new_option|version_removed"
  local -a deprecated=(
    # No deprecated options yet. Add entries as:
    # "@tiling_revamped_old_name|@tiling_revamped_new_name|3.0.0"
  )

  local entry old_opt new_opt removed_in value
  for entry in "${deprecated[@]}"; do
    old_opt="${entry%%|*}"
    local rest="${entry#*|}"
    new_opt="${rest%%|*}"
    removed_in="${rest##*|}"

    value=$(tmux show-option -gqv "${old_opt}" 2>/dev/null)
    if [[ -n "${value}" ]]; then
      tmux display-message \
        "tmux-tiling-revamped: '${old_opt}' is deprecated, use '${new_opt}' (removed in ${removed_in})" \
        2>/dev/null
    fi
  done
}

export -f _check_deprecated_options
