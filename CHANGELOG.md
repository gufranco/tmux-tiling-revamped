# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-20

### Added

- BSP layouts: dwindle (16 orientations) and spiral
- Built-in layouts: grid, main-center, monocle, deck
- Auto-reapplication via tmux hooks (after-split-window, after-kill-pane, pane-exited, window-resized)
- Layout operations: balance, equalize, rotate (90/180/270), flip (h/v)
- Pane operations: promote/demote, circulate (next/prev), autosplit (smart split direction)
- Focus-resize: expand focused pane toward golden ratio on focus change
- Layout cycling through configurable layout list
- Named pane marks with fzf jump-to-mark
- Named scratchpad popups via display-popup (tmux 3.2+)
- Layout presets: save and restore named configurations
- All keybindings configurable via @tiling_revamped_key_* options
- Per-window layout memory via tmux user options
- Recursion guard for hook-based auto-reapplication
- bats-core test suite
- CI for Ubuntu and macOS
