#!/usr/bin/env bash
#
# tiling.sh: command dispatcher for tmux-tiling-revamped.
#
# Called by keybindings and hooks via `run-shell`.  Sources all library
# modules and routes the first argument to the appropriate function.
#
# Usage:
#   tiling.sh layout dwindle [flags]
#   tiling.sh layout spiral  [flags]
#   tiling.sh layout grid
#   tiling.sh layout main-center
#   tiling.sh layout main-vertical
#   tiling.sh layout main-horizontal
#   tiling.sh layout monocle
#   tiling.sh layout deck
#   tiling.sh balance
#   tiling.sh equalize
#   tiling.sh rotate  [90|180|270]
#   tiling.sh flip    [h|v]
#   tiling.sh promote
#   tiling.sh circulate [next|prev]
#   tiling.sh autosplit
#   tiling.sh focus-resize
#   tiling.sh resize-master [grow|shrink]
#   tiling.sh sync
#   tiling.sh swap    [U|D|L|R]
#   tiling.sh cycle   [next|prev]
#   tiling.sh pick
#   tiling.sh mark    <name>
#   tiling.sh unmark  [name]
#   tiling.sh jump    [name]
#   tiling.sh scratchpad [name] [cmd]
#   tiling.sh preset  save <name>
#   tiling.sh preset  apply [name]
#   tiling.sh hook    split|kill|exit|resize|focus|new-window

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PLUGIN_DIR}/src/lib/utils/constants.sh"
source "${PLUGIN_DIR}/src/lib/utils/error-logger.sh"
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
source "${PLUGIN_DIR}/src/lib/tmux/tmux-config.sh"
source "${PLUGIN_DIR}/src/lib/layouts/dwindle.sh"
source "${PLUGIN_DIR}/src/lib/layouts/spiral.sh"
source "${PLUGIN_DIR}/src/lib/layouts/grid.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-center.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-vertical.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-horizontal.sh"
source "${PLUGIN_DIR}/src/lib/layouts/monocle.sh"
source "${PLUGIN_DIR}/src/lib/layouts/deck.sh"
source "${PLUGIN_DIR}/src/lib/operations/balance.sh"
source "${PLUGIN_DIR}/src/lib/operations/equalize.sh"
source "${PLUGIN_DIR}/src/lib/operations/rotate.sh"
source "${PLUGIN_DIR}/src/lib/operations/flip.sh"
source "${PLUGIN_DIR}/src/lib/operations/promote.sh"
source "${PLUGIN_DIR}/src/lib/operations/circulate.sh"
source "${PLUGIN_DIR}/src/lib/operations/autosplit.sh"
source "${PLUGIN_DIR}/src/lib/operations/focus-resize.sh"
source "${PLUGIN_DIR}/src/lib/operations/resize-master.sh"
source "${PLUGIN_DIR}/src/lib/operations/sync.sh"
source "${PLUGIN_DIR}/src/lib/operations/swap-direction.sh"
source "${PLUGIN_DIR}/src/lib/operations/pick-layout.sh"
source "${PLUGIN_DIR}/src/lib/features/marks.sh"
source "${PLUGIN_DIR}/src/lib/features/scratchpad.sh"
source "${PLUGIN_DIR}/src/lib/features/presets.sh"
source "${PLUGIN_DIR}/src/lib/features/cycle.sh"

_handle_hook() {
  local event="${1:-}"

  # Handle new-window: apply default layout if configured
  if [[ "${event}" == "new-window" ]]; then
    local default_layout
    default_layout=$(get_tmux_option "@tiling_revamped_default_layout" "")
    [[ -z "${default_layout}" ]] && return 0

    case "${default_layout}" in
      dwindle)         apply_layout_dwindle "" ;;
      spiral)          apply_layout_spiral "" ;;
      grid)            apply_layout_grid ;;
      main-center)     apply_layout_main_center ;;
      main-vertical)   apply_layout_main_vertical ;;
      main-horizontal) apply_layout_main_horizontal ;;
      monocle)         apply_layout_monocle ;;
      deck)            apply_layout_deck ;;
      *)               log_error "hook" "Unknown default layout: ${default_layout}" ;;
    esac
    return 0
  fi

  # Recursion guard: skip if a layout is currently being applied
  is_applying && return 0

  # Check if auto-apply is enabled for this window
  is_auto_apply_enabled || return 0

  local current_layout
  current_layout=$(get_current_layout)

  # No layout stored for this window: nothing to reapply
  [[ -z "${current_layout}" ]] && return 0

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  case "${current_layout}" in
    dwindle)         _apply_bsp_layout "false" "${flags}" ;;
    spiral)          _apply_bsp_layout "true"  "${flags}" ;;
    grid)            apply_layout_grid ;;
    main-center)     apply_layout_main_center ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    deck)            apply_layout_deck ;;
    monocle)         ;;
    *)               log_error "hook" "Unknown layout for reapplication: ${current_layout}" ;;
  esac
}

main() {
  local cmd="${1:-}"
  shift || true

  case "${cmd}" in
    layout)
      local layout_name="${1:-}"
      local layout_flags="${2:-}"
      case "${layout_name}" in
        dwindle)         apply_layout_dwindle "${layout_flags}" ;;
        spiral)          apply_layout_spiral  "${layout_flags}" ;;
        grid)            apply_layout_grid ;;
        main-center)     apply_layout_main_center ;;
        main-vertical)   apply_layout_main_vertical ;;
        main-horizontal) apply_layout_main_horizontal ;;
        monocle)         apply_layout_monocle ;;
        deck)            apply_layout_deck ;;
        *)
          log_error "tiling" "Unknown layout: ${layout_name}"
          exit 1
          ;;
      esac
      ;;
    balance)    balance_panes ;;
    equalize)   equalize_panes ;;
    rotate)     rotate_layout "${1:-90}" ;;
    flip)       flip_layout "${1:-h}" ;;
    promote)    promote_pane ;;
    circulate)  circulate_panes "${1:-next}" ;;
    autosplit)  autosplit_pane ;;
    focus-resize) focus_resize_pane ;;
    resize-master) resize_master "${1:-grow}" ;;
    sync)       sync_panes ;;
    swap)       swap_pane_direction "${1:-R}" ;;
    cycle)      cycle_layout "${1:-next}" ;;
    pick)       pick_layout ;;
    mark)       mark_pane "${1:-}" ;;
    unmark)     unmark_pane "${1:-}" ;;
    jump)       jump_to_mark "${1:-}" ;;
    scratchpad) toggle_scratchpad "${1:-default}" "${2:-}" ;;
    preset)
      local preset_cmd="${1:-}"
      local preset_name="${2:-}"
      case "${preset_cmd}" in
        save)  save_preset "${preset_name}" ;;
        apply) apply_preset "${preset_name}" ;;
        *)
          log_error "tiling" "Unknown preset command: ${preset_cmd}"
          exit 1
          ;;
      esac
      ;;
    hook)       _handle_hook "${1:-}" ;;
    *)
      log_error "tiling" "Unknown command: ${cmd}"
      exit 1
      ;;
  esac
}

main "$@"
