#!/usr/bin/env bash
# shellcheck disable=SC2034  # constants are sourced and used by other modules

[[ -n "${_TILING_REVAMPED_CONSTANTS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_CONSTANTS_LOADED=1

readonly TILING_REVAMPED_VERSION="1.0.0"

# Default orientation flags for BSP layouts
# Format: [t|b][l|r][h|v][c|s]
#   t/b  = top/bottom corner
#   l/r  = left/right corner
#   h/v  = horizontal/vertical branches
#   c/s  = corner/spiral trajectory
readonly TILING_DEFAULT_ORIENTATION="brvc"
readonly TILING_DEFAULT_MASTER_RATIO="60"
readonly TILING_DEFAULT_SPLIT_RATIO="50"
readonly TILING_DEFAULT_FOCUS_RATIO="62"
readonly TILING_DEFAULT_SCRATCH_WIDTH="80%"
readonly TILING_DEFAULT_SCRATCH_HEIGHT="75%"

# tmux option name constants (underscore convention matches yoru-revamped-tmux)
readonly OPT_LAYOUT="@tiling_revamped_layout"
readonly OPT_ENABLED="@tiling_revamped_enabled"
readonly OPT_APPLYING="@tiling_revamped_applying"
readonly OPT_ORIENTATION="@tiling_revamped_orientation"
readonly OPT_AUTO_APPLY="@tiling_revamped_auto_apply"
readonly OPT_FOCUS_RESIZE="@tiling_revamped_focus_resize"
readonly OPT_MARKS="@tiling_revamped_marks"

readonly OPT_KEY_DWINDLE="@tiling_revamped_key_dwindle"
readonly OPT_KEY_SPIRAL="@tiling_revamped_key_spiral"
readonly OPT_KEY_BALANCE="@tiling_revamped_key_balance"
readonly OPT_KEY_EQUALIZE="@tiling_revamped_key_equalize"
readonly OPT_KEY_PROMOTE="@tiling_revamped_key_promote"
readonly OPT_KEY_ROTATE="@tiling_revamped_key_rotate"
readonly OPT_KEY_FLIP="@tiling_revamped_key_flip"
readonly OPT_KEY_CIRCULATE="@tiling_revamped_key_circulate"
readonly OPT_KEY_AUTOTILE="@tiling_revamped_key_autotile"
readonly OPT_KEY_CYCLE="@tiling_revamped_key_cycle"
readonly OPT_KEY_MARK="@tiling_revamped_key_mark"
readonly OPT_KEY_JUMP="@tiling_revamped_key_jump"
readonly OPT_KEY_SCRATCHPAD="@tiling_revamped_key_scratchpad"
