# tmux-tiling-revamped

BSP tiling window management for tmux. Brings dwindle, spiral, grid, main-center, monocle, and deck layouts to tmux with automatic reapplication, pane operations, marks, scratchpads, and full configurability.

Inspired by bspwm, Hyprland, dwm, i3, and sunaku's tmux-layout-dwindle.

## Requirements

- tmux 3.2+
- bash 4.0+
- [TPM](https://github.com/tmux-plugins/tpm)
- fzf (optional, for mark jump and preset selection)

## Install

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'gufranco/tmux-tiling-revamped'
```

Press `prefix + I` to install via TPM.

## Layouts

| Layout | Description |
|--------|-------------|
| dwindle | BSP cascade toward a corner. 16 orientations via `[t\|b][l\|r][h\|v][c\|s]` flags |
| spiral | BSP with split direction rotating every ~5 panes. Same 16 orientations |
| grid | Even N x M grid (tmux tiled) |
| main-center | Wide center pane with narrow side panes |
| monocle | Zoom focused pane to fill window. Toggle to restore |
| deck | All panes full-height at equal widths |

### BSP orientation flags

The dwindle and spiral layouts accept a 4-character orientation string:

| Position | Options | Meaning |
|----------|---------|---------|
| 1 | `t` / `b` | Top or bottom corner |
| 2 | `l` / `r` | Left or right corner |
| 3 | `h` / `v` | Horizontal or vertical branch direction |
| 4 | `c` / `s` | Corner or spiral trajectory |

Default: `brvc` (bottom-right, vertical, corner).

## Default keybindings

All keybindings use the tmux prefix key. Every key is configurable.

| Key | Action |
|-----|--------|
| `d` | Apply dwindle layout |
| `D` | Apply spiral layout |
| `b` | Balance panes |
| `B` | Equalize panes |
| `m` | Promote focused pane to master |
| `.` | Rotate layout 90 degrees |
| `,` | Flip layout horizontally |
| `C-r` | Circulate panes |
| `C-d` | Smart split (autotile along longest axis) |
| `o` | Cycle to next layout |
| `M` | Mark pane (prompts for name) |
| `j` | Jump to marked pane (fzf picker if available) |
| `g` | Toggle scratchpad popup |

## Configuration

All options use the `@tiling_revamped_` prefix with underscores.

```tmux
# Auto-reapply layout when panes change (default: 1)
set -g @tiling_revamped_auto_apply 1

# Default BSP orientation (default: brvc)
set -g @tiling_revamped_default_orientation "brvc"

# Focus-resize: expand focused pane toward golden ratio (default: 0)
set -g @tiling_revamped_focus_resize 0
set -g @tiling_revamped_focus_ratio 62

# Main-center layout ratio (default: 60)
set -g @tiling_revamped_main_center_ratio 60

# Layout cycle order
set -g @tiling_revamped_cycle_layouts "dwindle spiral grid main-center monocle"

# Scratchpad dimensions
set -g @tiling_revamped_scratch_width "80%"
set -g @tiling_revamped_scratch_height "75%"

# Debug logging (default: 0)
set -g @tiling_revamped_enable_logging 0
```

### Custom keybindings

```tmux
set -g @tiling_revamped_key_dwindle    "d"
set -g @tiling_revamped_key_spiral     "D"
set -g @tiling_revamped_key_balance    "b"
set -g @tiling_revamped_key_equalize   "B"
set -g @tiling_revamped_key_promote    "m"
set -g @tiling_revamped_key_rotate     "."
set -g @tiling_revamped_key_flip       ","
set -g @tiling_revamped_key_circulate  "C-r"
set -g @tiling_revamped_key_autotile   "C-d"
set -g @tiling_revamped_key_cycle      "o"
set -g @tiling_revamped_key_mark       "M"
set -g @tiling_revamped_key_jump       "j"
set -g @tiling_revamped_key_scratchpad "g"
```

### i3-style Alt keybindings

To use Alt-based bindings without the prefix key:

```tmux
bind -n M-d run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh layout dwindle"
bind -n M-D run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh layout spiral"
bind -n M-g run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh layout grid"
bind -n M-m run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh promote"
bind -n M-o run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh cycle"
bind -n M-e run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh autosplit"
```

## CLI

The plugin exposes `src/tiling.sh` as a command-line dispatcher. All operations can be called directly:

```bash
# Apply layouts
./src/tiling.sh layout dwindle brvc
./src/tiling.sh layout spiral
./src/tiling.sh layout grid
./src/tiling.sh layout main-center
./src/tiling.sh layout monocle
./src/tiling.sh layout deck

# Operations
./src/tiling.sh balance
./src/tiling.sh equalize
./src/tiling.sh rotate 90
./src/tiling.sh rotate 180
./src/tiling.sh flip h
./src/tiling.sh flip v
./src/tiling.sh promote
./src/tiling.sh circulate next
./src/tiling.sh circulate prev
./src/tiling.sh autosplit
./src/tiling.sh focus-resize

# Features
./src/tiling.sh cycle next
./src/tiling.sh cycle prev
./src/tiling.sh mark editor
./src/tiling.sh jump editor
./src/tiling.sh scratchpad htop
./src/tiling.sh preset save dev
./src/tiling.sh preset apply dev
```

## How it works

The plugin uses sunaku's proven BSP algorithm: flatten all panes to `even-vertical`, rearrange via `move-pane` with orientation-aware flags, then binary-halve sizes in a second pass. All tmux commands are batched in a single invocation to prevent flicker.

State is stored in tmux user options at the appropriate scope:

| Option | Scope | Purpose |
|--------|-------|---------|
| `@tiling_revamped_layout` | window | Current layout name |
| `@tiling_revamped_orientation` | window | BSP orientation flags |
| `@tiling_revamped_applying` | global | Recursion guard |
| `@tiling_revamped_mark` | pane | Mark name |
| `@tiling_revamped_marks` | global | Mark index |

Auto-reapplication uses hook arrays (`after-split-window[100]`, etc.) to avoid colliding with other plugins.

## Development

```bash
# Run the full test suite
make test

# Run unit tests only
make test-unit

# Run shellcheck
make lint
```

## License

MIT
