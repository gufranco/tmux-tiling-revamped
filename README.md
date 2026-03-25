<div align="center">

<h1>tmux-tiling-revamped</h1>

<strong>BSP tiling window management for tmux. Eight layouts, eleven operations, zero dependencies.</strong>

<br>
<br>

[![CI](https://github.com/gufranco/tmux-tiling-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-tiling-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/github/license/gufranco/tmux-tiling-revamped?style=flat-square)](LICENSE)
[![tmux](https://img.shields.io/badge/tmux-3.2%2B-green?style=flat-square)](https://github.com/tmux/tmux)
[![bash](https://img.shields.io/badge/bash-4.0%2B-blue?style=flat-square)](https://www.gnu.org/software/bash/)

</div>

---

**8** layouts  ·  **16** BSP orientations  ·  **11** operations  ·  **18** keybindings  ·  **368** tests  ·  **zero** dependencies

<table>
<tr>
<td width="50%" valign="top">

### BSP Tiling

Dwindle and spiral layouts with 16 orientation variants. Panes cascade into binary space partitions toward any corner, horizontally or vertically.

</td>
<td width="50%" valign="top">

### Auto-Reapplication

Hooks on split, kill, exit, and resize automatically reapply the current layout. A recursion guard prevents infinite hook chains.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### Tree Operations

Rotate 90/180/270 degrees, flip horizontally or vertically, promote any pane to master, circulate pane positions forward or backward.

</td>
<td width="50%" valign="top">

### Named Scratchpads

Toggle persistent popup windows backed by detached tmux sessions. Multiple named scratchpads, each with configurable dimensions.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### Pane Marks

Label any pane with a name and jump to it instantly. Uses fzf for fuzzy selection when available, direct name lookup otherwise.

</td>
<td width="50%" valign="top">

### Layout Presets

Save and restore named configurations that capture the layout, orientation flags, and master ratio. Switch between workflows in one keystroke.

</td>
</tr>
</table>

## Why

tmux has five built-in layouts. None of them do BSP tiling. The existing plugins each solve a piece of the puzzle but leave gaps.

| Capability | tiling-revamped | tmux-tilish | dwm.tmux | tmex |
|:-----------|:---------------:|:-----------:|:--------:|:----:|
| BSP layouts | Yes | No | No | No |
| Spiral trajectory | Yes | No | No | No |
| Main-vertical/horizontal | Yes | Yes | Yes | No |
| Auto-reapplication | Yes | Yes | No | No |
| Default layout for new windows | Yes | Yes | No | No |
| Rotate / flip | Yes | No | No | No |
| Promote / demote | Yes | No | Yes | No |
| Master ratio resize | Yes | No | Yes | No |
| Directional swap | Yes | Yes | No | No |
| Synchronize panes | Yes | Yes | No | No |
| Alt keybinding mode | Yes | Yes | No | No |
| Vim-aware navigation | Yes | Yes | No | No |
| Named scratchpads | Yes | No | No | No |
| Pane marks | Yes | No | No | No |
| Layout presets | Yes | No | No | No |
| TPM installable | Yes | Yes | Yes | No |

## Architecture

```mermaid
graph LR
    K[Keybinding] --> D[tiling.sh<br>Dispatcher]
    H[tmux Hook] --> D
    D --> L[Layouts<br>8 modules]
    D --> O[Operations<br>11 modules]
    D --> F[Features<br>4 modules]
    L --> T[Batched tmux<br>Commands]
    O --> T
    F --> T
    T --> S[(tmux State<br>User Options)]
    S -.->|auto-reapply| H
```

State is stored in tmux user options at window, pane, or global scope. No temp files, no external state.

## Layouts

### Dwindle

BSP cascade toward a corner. Each new pane takes half of the remaining space. The master pane holds the largest area, and subsequent panes get progressively smaller.

**2 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │                   │
│         1         │         2         │
│                   │                   │
│                   │                   │
└───────────────────┴───────────────────┘
```

**3 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├───────────────────┤
│                   │                   │
│                   │         3         │
└───────────────────┴───────────────────┘
```

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├─────────┬─────────┤
│                   │         │         │
│                   │    3    │    4    │
└───────────────────┴─────────┴─────────┘
```

**5 panes**

```
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   │                   │
│         1         ├─────────┬─────────┤
│                   │         │    4    │
│                   │    3    ├─────────┤
│                   │         │    5    │
└───────────────────┴─────────┴─────────┘
```

### Spiral

Same BSP algorithm as dwindle, but the split direction rotates every few panes, creating a spiral convergence pattern instead of a straight cascade toward a corner.

**5 panes**

```
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   │                   │
│         1         ├───────────────────┤
│                   │         3         │
│                   ├─────────┬─────────┤
│                   │    5    │    4    │
└───────────────────┴─────────┴─────────┘
```

Note how pane 5 appears to the left of pane 4. In the dwindle layout, pane 4 would be on top with 5 below. The spiral trajectory reverses the direction at that depth, creating the inward rotation.

### Grid

Even N x M grid. Uses tmux's built-in tiled layout for fair distribution.

**4 panes**

```
┌───────────────────┬───────────────────┐
│                   │                   │
│         1         │         2         │
│                   │                   │
├───────────────────┼───────────────────┤
│                   │                   │
│         3         │         4         │
│                   │                   │
└───────────────────┴───────────────────┘
```

**6 panes**

```
┌────────────┬─────────────┬────────────┐
│            │             │            │
│     1      │      2      │     3      │
│            │             │            │
├────────────┼─────────────┼────────────┤
│            │             │            │
│     4      │      5      │     6      │
│            │             │            │
└────────────┴─────────────┴────────────┘
```

### Main-Center

Wide center pane for the primary task, narrow side panes for secondary content. The center ratio is configurable via `@tiling_revamped_main_center_ratio`.

**3 panes**

```
┌───────┬───────────────────────┬───────┐
│       │                       │       │
│       │                       │       │
│   2   │           1           │   3   │
│       │                       │       │
│       │                       │       │
└───────┴───────────────────────┴───────┘
```

**5 panes**

```
┌───────┬───────────────────────┬───────┐
│       │                       │   3   │
│       │                       ├───────┤
│   2   │           1           │   4   │
│       │                       ├───────┤
│       │                       │   5   │
└───────┴───────────────────────┴───────┘
```

### Monocle

Zoom the focused pane to fill the entire window. Other panes are hidden behind the zoom. Press the same key again to toggle back to the previous layout.

```
┌───────────────────────────────────────┐
│                                       │
│                                       │
│               1 [zoom]                │
│                                       │
│                                       │
│                                       │
└───────────────────────────────────────┘
        panes 2, 3, 4 behind zoom
```

### Deck

All panes at full height, side by side at equal widths. Each pane is a "card" in the deck.

**3 panes**

```
┌────────────┬─────────────┬────────────┐
│            │             │            │
│            │             │            │
│     1      │      2      │     3      │
│            │             │            │
│            │             │            │
└────────────┴─────────────┴────────────┘
```

### Main-Vertical

One large left pane (master), remaining panes stacked vertically on the right. Wraps tmux's built-in `main-vertical` layout. Master size controlled by `@tiling_revamped_master_ratio`.

**3 panes**

```
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   │                   │
│         1         ├───────────────────┤
│                   │         3         │
│                   │                   │
└───────────────────┴───────────────────┘
```

**5 panes**

```
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   ├───────────────────┤
│         1         │         3         │
│                   ├───────────────────┤
│                   │         4         │
│                   ├───────────────────┤
│                   │         5         │
└───────────────────┴───────────────────┘
```

### Main-Horizontal

One large top pane (master), remaining panes placed side by side below. Wraps tmux's built-in `main-horizontal` layout. Master size controlled by `@tiling_revamped_master_ratio`.

**3 panes**

```
┌───────────────────────────────────────┐
│                                       │
│                  1                    │
│                                       │
├───────────────────┬───────────────────┤
│         2         │         3         │
└───────────────────┴───────────────────┘
```

**5 panes**

```
┌───────────────────────────────────────┐
│                                       │
│                  1                    │
│                                       │
├─────────┬─────────┬─────────┬─────────┤
│    2    │    3    │    4    │    5    │
└─────────┴─────────┴─────────┴─────────┘
```

## BSP Orientation Flags

The dwindle and spiral layouts accept a 4-character orientation string that controls where panes cascade. Default: `brvc`.

| Position | Options | Meaning |
|:---------|:--------|:--------|
| 1 | `t` / `b` | Top or bottom corner |
| 2 | `l` / `r` | Left or right corner |
| 3 | `h` / `v` | Horizontal or vertical branch direction |
| 4 | `c` / `s` | Corner or spiral trajectory |

This produces 16 distinct arrangements. Here are the four most visually distinct variants with 4 panes:

**`brvc`** bottom-right, vertical, corner (default)

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
```

**`tlvc`** top-left, vertical, corner

```
┌─────┬─────┬───────────┐
│  4  │  3  │           │
├─────┴─────┤     1     │
│     2     │           │
└───────────┴───────────┘
```

**`brhc`** bottom-right, horizontal, corner

```
┌───────────────────────┐
│           1           │
├───────────┬───────────┤
│           │     3     │
│     2     ├───────────┤
│           │     4     │
└───────────┴───────────┘
```

**`blvc`** bottom-left, vertical, corner

```
┌───────────┬───────────┐
│     2     │           │
├─────┬─────┤     1     │
│  4  │  3  │           │
└─────┴─────┴───────────┘
```

## Operations

### Promote

Swap the focused pane with the master pane. If the focused pane is already master, demote it to position 2.

**Before** - pane C is focused:

```
┌───────────┬───────────┐
│           │     B     │
│     A     ├─────┬─────┤
│           │ [C] │  D  │
└───────────┴─────┴─────┘
```

**After** - pane C is now master:

```
┌───────────┬───────────┐
│           │     B     │
│     C     ├─────┬─────┤
│           │  A  │  D  │
└───────────┴─────┴─────┘
```

### Rotate

Rotate the BSP orientation by 90, 180, or 270 degrees. This swaps the branch direction between vertical and horizontal splits.

**Before** `brvc` - vertical branches:

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
```

**After** `brhc` - rotated 90, horizontal branches:

```
┌───────────────────────┐
│           1           │
├───────────┬───────────┤
│           │     3     │
│     2     ├───────────┤
│           │     4     │
└───────────┴───────────┘
```

### Flip

Mirror the layout along one axis. Flip horizontal swaps left/right, flip vertical swaps top/bottom.

**Before** `brvc` - cascade toward bottom-right:

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
```

**After** `blvc` - flipped horizontal, cascade toward bottom-left:

```
┌───────────┬───────────┐
│     2     │           │
├─────┬─────┤     1     │
│  4  │  3  │           │
└─────┴─────┴───────────┘
```

### Circulate

Shift all pane contents one position forward or backward through the layout slots. The layout topology stays the same, only the content moves.

**Before:**

```
┌───────────┬───────────┐
│           │     B     │
│     A     ├─────┬─────┤
│           │  C  │  D  │
└───────────┴─────┴─────┘
```

**After** circulate next:

```
┌───────────┬───────────┐
│           │     A     │
│     D     ├─────┬─────┤
│           │  B  │  C  │
└───────────┴─────┴─────┘
```

### Balance

Equalize all pane sizes while preserving the current layout topology.

**Before** - uneven sizes:

```
┌──────────────────┬────┐
│                  │ 2  │
│        1         ├──┬─┤
│                  │3 │4│
└──────────────────┴──┴─┘
```

**After** - balanced:

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
```

### Equalize

Ignore the current layout and distribute all panes evenly along one axis.

```
┌───────────────────────┐
│           1           │
├───────────────────────┤
│           2           │
├───────────────────────┤
│           3           │
├───────────────────────┤
│           4           │
└───────────────────────┘
```

### Autosplit

Split the focused pane along its longest axis. Wide panes split horizontally, tall panes split vertically.

**Wide pane** - splits horizontally:

```
┌───────────────────────┐
│                       │
│       wide pane       │
│                       │
└───────────────────────┘

┌───────────┬───────────┐
│           │           │
│   left    │   right   │
│           │           │
└───────────┴───────────┘
```

**Tall pane** - splits vertically:

```
┌───────────────────────┐
│                       │
│       tall pane       │
│                       │
│                       │
└───────────────────────┘

┌───────────────────────┐
│         top           │
├───────────────────────┤
│        bottom         │
│                       │
└───────────────────────┘
```

### Focus-Resize

When enabled, the focused pane automatically expands toward the golden ratio on every focus change. Other panes shrink proportionally.

**Before** - pane 3 receives focus:

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │ [3] │  4  │
└───────────┴─────┴─────┘
```

**After** - pane 3 expanded to 62% ratio:

```
┌──────┬────────────────┐
│      │       2        │
│  1   ├────────────┬───┤
│      │    [3]     │ 4 │
└──────┴────────────┴───┘
```

### Resize Master

Grow or shrink the master pane by a configurable step (`@tiling_revamped_resize_step`, default 5%). For main-vertical, main-horizontal, and main-center layouts, adjusts the stored ratio and re-applies. For other layouts, resizes the first pane directly.

### Synchronize Panes

Toggle `synchronize-panes` for the current window. When active, all keystrokes are broadcast to every pane simultaneously. Useful for running the same command across multiple servers.

### Directional Swap

Swap the focused pane with its neighbor in a given direction (up, down, left, right). After swapping, the layout is re-applied so sizes recalculate for the new positions.

**Before** - pane C is focused, swap right:

```
┌───────────┬───────────┐
│           │     B     │
│     A     ├─────┬─────┤
│           │ [C] │  D  │
└───────────┴─────┴─────┘
```

**After** - pane C swapped with pane D:

```
┌───────────┬───────────┐
│           │     B     │
│     A     ├─────┬─────┤
│           │  D  │ [C] │
└───────────┴─────┴─────┘
```

## Features

### Layout Cycling

Step forward or backward through a configurable list of layouts. The cycle order is set via `@tiling_revamped_cycle_layouts`.

```
       prefix+o    prefix+o    prefix+o       prefix+o          prefix+o
dwindle --> spiral --> grid --> main-vertical --> main-horizontal --> main-center --+
   ^                                                                               |
   +--  monocle  <-----------------------------------------------------------------+
```

### Pane Marks

Label any pane with a name. Jump to any marked pane with fzf fuzzy selection or by name.

```
┌───────────────────┬───────────────────┐
│                   │                   │
│   mark: build     │   mark: editor    │
│                   ├─────────┬─────────┤
│                   │         │  mark:  │
│                   │         │   log   │
└───────────────────┴─────────┴─────────┘

  prefix + M  -->  set mark on focused pane
  prefix + j  -->  fzf picker to jump to any mark
```

### Named Scratchpads

Toggle floating popup windows backed by persistent tmux sessions. Each scratchpad keeps its state between toggles. Requires tmux 3.2+ for `display-popup`.

```
┌───────────────────────────────────────┐
│                                       │
│   ┌───────────────────────────────┐   │
│   │                               │   │
│   │      scratchpad: htop         │   │
│   │                               │   │
│   │   (persistent popup session)  │   │
│   │                               │   │
│   └───────────────────────────────┘   │
│                                       │
│       underlying panes still run      │
└───────────────────────────────────────┘
```

### Layout Presets

Save the current layout, orientation, and master ratio as a named preset. Restore it later to switch between workflows instantly.

**Save** current state as "dev":

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
  -> dwindle:brvc:60
```

**Apply** "dev" to restore:

```
┌───────────┬───────────┐
│           │     2     │
│     1     ├─────┬─────┤
│           │  3  │  4  │
└───────────┴─────┴─────┘
  <- dwindle:brvc:60
```

## Quick Start

### Prerequisites

| Tool | Version | Install |
|:-----|:--------|:--------|
| tmux | 3.2+ | [github.com/tmux/tmux](https://github.com/tmux/tmux) |
| bash | 4.0+ | Ships with Linux. macOS: `brew install bash` |
| TPM | latest | [github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) |
| fzf | any | Optional. Enables fuzzy mark/preset selection |

### Install

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'gufranco/tmux-tiling-revamped'
```

Press `prefix + I` to install via TPM.

### Verify

Open tmux, create a few panes, then press `prefix + d`. All panes rearrange into a dwindle layout.

## Default Keybindings

All keybindings use the tmux prefix. Every key is configurable via `@tiling_revamped_key_*` options.

| Key | Action | Command |
|:----|:-------|:--------|
| `d` | Apply dwindle layout | `layout dwindle` |
| `D` | Apply spiral layout | `layout spiral` |
| `v` | Apply main-vertical layout | `layout main-vertical` |
| `V` | Apply main-horizontal layout | `layout main-horizontal` |
| `b` | Balance panes | `balance` |
| `B` | Equalize panes | `equalize` |
| `m` | Promote focused pane to master | `promote` |
| `.` | Rotate layout 90 degrees | `rotate` |
| `,` | Flip layout horizontally | `flip` |
| `C-r` | Circulate panes | `circulate` |
| `C-d` | Smart split along longest axis | `autosplit` |
| `o` | Cycle to next layout | `cycle` |
| `+` | Grow master pane | `resize-master grow` |
| `-` | Shrink master pane | `resize-master shrink` |
| `S` | Toggle synchronize panes | `sync` |
| `M` | Mark pane with a name | `mark <name>` |
| `j` | Jump to marked pane | `jump` |
| `g` | Toggle scratchpad popup | `scratchpad` |

## Configuration

All options use the `@tiling_revamped_` prefix.

### Behavior

| Option | Default | Description |
|:-------|:--------|:------------|
| `@tiling_revamped_auto_apply` | `1` | Reapply layout when panes are added or removed |
| `@tiling_revamped_default_layout` | (empty) | Auto-apply this layout on new windows. Values: `dwindle`, `spiral`, `grid`, `main-vertical`, `main-horizontal`, `main-center`, `deck` |
| `@tiling_revamped_default_orientation` | `brvc` | Default BSP orientation for new windows |
| `@tiling_revamped_focus_resize` | `0` | Expand focused pane toward golden ratio on focus |
| `@tiling_revamped_focus_ratio` | `62` | Percentage of window for focused pane |
| `@tiling_revamped_master_ratio` | `60` | Master pane percentage for main-vertical and main-horizontal |
| `@tiling_revamped_main_center_ratio` | `60` | Width percentage for main-center center pane |
| `@tiling_revamped_resize_step` | `5` | Percentage step for resize-master grow/shrink |
| `@tiling_revamped_cycle_layouts` | `dwindle spiral grid main-vertical main-horizontal main-center monocle` | Layout cycle order |
| `@tiling_revamped_alt_keys` | `0` | Use Alt keybindings (`M-<key>`) instead of prefix mode |
| `@tiling_revamped_navigator` | `0` | Vim-aware navigation. Set to `1` to enable `M-h/j/k/l` with vim detection |
| `@tiling_revamped_scratch_width` | `80%` | Scratchpad popup width |
| `@tiling_revamped_scratch_height` | `75%` | Scratchpad popup height |
| `@tiling_revamped_enable_logging` | `0` | Write debug logs to `~/.tmux/tiling-logs/` |

### Custom Keybindings

```tmux
set -g @tiling_revamped_key_dwindle         "d"
set -g @tiling_revamped_key_spiral          "D"
set -g @tiling_revamped_key_main_vertical   "v"
set -g @tiling_revamped_key_main_horizontal "V"
set -g @tiling_revamped_key_balance         "b"
set -g @tiling_revamped_key_equalize        "B"
set -g @tiling_revamped_key_promote         "m"
set -g @tiling_revamped_key_rotate          "."
set -g @tiling_revamped_key_flip            ","
set -g @tiling_revamped_key_circulate       "C-r"
set -g @tiling_revamped_key_autotile        "C-d"
set -g @tiling_revamped_key_cycle           "o"
set -g @tiling_revamped_key_master_grow     "+"
set -g @tiling_revamped_key_master_shrink   "-"
set -g @tiling_revamped_key_sync            "S"
set -g @tiling_revamped_key_mark            "M"
set -g @tiling_revamped_key_jump            "j"
set -g @tiling_revamped_key_scratchpad      "g"

# Directional swap (disabled by default, set keys to enable)
set -g @tiling_revamped_key_swap_up    ""
set -g @tiling_revamped_key_swap_down  ""
set -g @tiling_revamped_key_swap_left  ""
set -g @tiling_revamped_key_swap_right ""
```

### i3-style Alt Keybindings

Enable built-in Alt key mode to bind all actions to `Alt+<key>` without the prefix:

```tmux
set -g @tiling_revamped_alt_keys 1
```

This changes all keybindings from `prefix + <key>` to `Alt + <key>` automatically. The key values remain configurable per-action.

Alternatively, define manual Alt bindings for specific actions:

```tmux
bind -n M-d run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh layout dwindle"
bind -n M-v run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh layout main-vertical"
bind -n M-m run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh promote"
bind -n M-o run-shell "~/.tmux/plugins/tmux-tiling-revamped/src/tiling.sh cycle"
```

### macOS: Configuring the Option Key as Meta

On macOS, the Option (Alt) key does not send Meta/ESC sequences by default. Instead, it inserts special Unicode characters. For example, Option+g produces `©` instead of the `ESC g` sequence that tmux expects for `M-g` bindings.

This affects all `Alt+<key>` bindings in tmux, including alt key mode and vim-aware navigation. Without the fix below, none of the `M-` keybindings will work on macOS.

#### Why This Happens

Terminal emulators on macOS follow Apple's input method convention: the Option key is a modifier for accented characters and symbols. When you press Option+e followed by a vowel, you get an accented letter. This is useful for typing in languages like French, Spanish, and Portuguese, but it means the Option key never reaches tmux as a Meta modifier.

tmux `M-g` means "Meta+g", which the terminal must send as the two-byte sequence `ESC g` (0x1B followed by 0x67). When the terminal sends `©` (0xC2 0xA9) instead, tmux sees an unknown character and ignores it.

#### Fixing iTerm2

1. Open **iTerm2 > Settings** (Cmd+,)
2. Go to **Profiles > Keys > General**
3. Find **Left Option key** and change it from "Normal" to **"Esc+"**
4. Repeat for **Right Option key** if you want both sides to work as Meta
5. Close Settings

#### Fixing Terminal.app

1. Open **Terminal > Settings** (Cmd+,)
2. Go to **Profiles** and select your active profile
3. Go to the **Keyboard** tab
4. Check **"Use Option as Meta key"**
5. Close Settings

#### Fixing Kitty

Kitty on macOS sends Option key as Meta by default. No configuration change is needed. If it was changed, verify `~/.config/kitty/kitty.conf` contains:

```
macos_option_as_alt yes
```

#### Fixing Ghostty

Add to `~/.config/ghostty/config`:

```
macos-option-as-alt = true
```

#### Fixing Alacritty

Alacritty on macOS does not require configuration. Option keys are sent as Alt/Meta by default.

#### Fixing WezTerm

Add to `~/.config/wezterm/wezterm.lua`:

```lua
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
```

#### After Changing the Setting

The terminal emulator change does not propagate to already-running tmux sessions. tmux caches terminal capabilities when a client first connects. To pick up the new setting:

1. Detach from tmux: `Prefix + d` or run `tmux detach`
2. Close the terminal tab or window
3. Open a new terminal window
4. Reattach: `tmux attach`

Alternatively, kill the tmux server entirely and start fresh:

```bash
tmux kill-server
tmux new-session
```

#### Trade-off

Switching Option to Esc+ means you lose the ability to type special characters via Option+key in the terminal. Accented letters, currency symbols, and typographic characters that macOS normally produces through Option combinations will no longer be available through the Option modifier inside terminal applications.

For most development workflows this is acceptable. If you need occasional special character input, you can:

- Use the macOS Character Viewer (Ctrl+Cmd+Space) to insert special characters
- Configure only the **left** Option key as Esc+ and keep the **right** Option key as "Normal" for special characters
- Switch the setting back temporarily when needed

### Vim-Aware Navigation

Enable seamless navigation between tmux panes and vim splits. When the active pane runs vim/nvim/fzf, navigation keys are forwarded to the program instead of moving the tmux selection.

```tmux
set -g @tiling_revamped_navigator 1
```

This registers `Alt+h/j/k/l` for directional navigation with automatic vim detection via `#{pane_current_command}` inspection.

## CLI

The dispatcher at `src/tiling.sh` accepts direct commands for scripting and custom bindings.

```bash
# Layouts
./src/tiling.sh layout dwindle brvc
./src/tiling.sh layout spiral
./src/tiling.sh layout grid
./src/tiling.sh layout main-center
./src/tiling.sh layout main-vertical
./src/tiling.sh layout main-horizontal
./src/tiling.sh layout monocle
./src/tiling.sh layout deck

# Operations
./src/tiling.sh balance
./src/tiling.sh equalize
./src/tiling.sh rotate 180
./src/tiling.sh flip v
./src/tiling.sh promote
./src/tiling.sh circulate prev
./src/tiling.sh autosplit
./src/tiling.sh focus-resize
./src/tiling.sh resize-master grow
./src/tiling.sh resize-master shrink
./src/tiling.sh sync
./src/tiling.sh swap R
./src/tiling.sh swap U

# Features
./src/tiling.sh cycle next
./src/tiling.sh mark editor
./src/tiling.sh jump editor
./src/tiling.sh scratchpad htop
./src/tiling.sh preset save dev
./src/tiling.sh preset apply dev
```

## How It Works

The core BSP algorithm computes a tmux custom layout string mathematically, then applies it in a single `select-layout` call.

**Step 1: Build** - `_bsp_build()` recursively divides the window into a binary tree. At each depth, the orientation flags determine whether the split is horizontal or vertical and which child gets the current pane. The output is a tmux layout string encoding every leaf's position, size, and pane ID:

```
200x50,0,0{100x50,0,0,0,100x50,101,0[100x24,101,0,1,100x25,101,25{50x25,101,25,2,49x25,152,25,3}]}
```

**Step 2: Checksum** - `_layout_checksum()` computes the CRC-16 checksum that tmux requires as a prefix to custom layout strings.

**Step 3: Apply** - `select-layout <checksum>,<layout_body>` positions all panes in one call. For spiral layouts, `_bsp_fix_pane_order()` then swaps panes so each pane occupies the correct BSP depth position.

State is stored in tmux user options:

| Option | Scope | Purpose |
|:-------|:------|:--------|
| `@tiling_revamped_layout` | window | Current layout name |
| `@tiling_revamped_orientation` | window | BSP orientation flags |
| `@tiling_revamped_applying` | global | Recursion guard |
| `@tiling_revamped_mark` | pane | Mark name |
| `@tiling_revamped_marks` | global | Mark index |

Auto-reapplication uses hook arrays at index 100 to avoid colliding with other plugins.

<details>
<summary><strong>Project structure</strong></summary>

```
tmux-tiling-revamped.tmux     # TPM entry point: keybindings and hooks
src/
  tiling.sh                   # Command dispatcher
  lib/
    layouts/
      dwindle.sh              # BSP dwindle + shared _apply_bsp_layout
      spiral.sh               # BSP spiral (delegates to dwindle)
      grid.sh                 # Even grid via tmux tiled
      main-center.sh          # Wide center pane with side columns
      main-vertical.sh        # Master left, stack right
      main-horizontal.sh      # Master top, stack bottom
      monocle.sh              # Zoom toggle
      deck.sh                 # Full-height equal-width stack
    operations/
      balance.sh              # Equalize sizes within current topology
      equalize.sh             # Force even distribution
      rotate.sh               # Rotate orientation 90/180/270
      flip.sh                 # Mirror horizontally or vertically
      promote.sh              # Swap focused pane with master
      circulate.sh            # Shift pane positions
      autosplit.sh            # Smart split along longest axis
      focus-resize.sh         # Golden ratio resize on focus
      resize-master.sh        # Grow or shrink master pane
      sync.sh                 # Toggle synchronize-panes
      swap-direction.sh       # Swap pane with directional neighbor
    features/
      marks.sh                # Named pane labels with fzf jump
      scratchpad.sh           # Persistent popup sessions
      presets.sh              # Save and restore layout configs
      cycle.sh                # Step through layout list
    tmux/
      tmux-ops.sh             # Get/set tmux options at all scopes
      tmux-config.sh          # Option helpers: enabled, numeric, guards
    utils/
      constants.sh            # Readonly option names and defaults
      error-logger.sh         # Rotating log file
      has-command.sh           # Command existence check
test/
  helpers.bash                # Mock tmux for unit tests
  tmux_helpers.bash           # Real tmux server for integration tests
  lib/                        # 28 bats test files mirroring src/lib/
examples/
  minimal.tmux.conf           # Drop-in config with defaults
  power-user.tmux.conf        # Full config with all options
```

</details>

## Development

| Command | Description |
|:--------|:------------|
| `make test` | Run the full 366-test bats suite |
| `make test-unit` | Run unit tests only |
| `make lint` | ShellCheck all shell files |
| `make clean` | Remove temp test artifacts |

## License

[MIT](LICENSE)
