# Contributing

## Getting Started

```bash
git clone https://github.com/gufranco/tmux-tiling-revamped.git
cd tmux-tiling-revamped
bats --recursive test/
```

Requirements: bash 4.0+, tmux 3.2+, bats-core, shellcheck.

## Adding a New Layout

1. Create `src/lib/layouts/<name>.sh` with:
   - Source guard (`_TILING_REVAMPED_<NAME>_LOADED`)
   - Source `tmux-config.sh`
   - `apply_layout_<name>()` function with:
     - `get_pane_count` early return for single pane
     - `trap 'set_applying 0' RETURN` and `set_applying 1`
     - `set_current_layout "<name>"` at the end
   - `TILING_PREVIEW_<NAME>` exported variable with ASCII diagram
   - `export -f apply_layout_<name>`

2. Source the file in `src/tiling.sh`

3. Add to the dispatcher case in `main()` under the `layout)` branch

4. Add to `PICK_LAYOUTS` array in `src/lib/operations/pick-layout.sh`

5. Add to default cycle list in `src/lib/features/cycle.sh`

6. Add to `_handle_hook` new-window and reapply cases in `src/tiling.sh`

7. Add to `_reapply_current_layout` in `src/lib/tmux/tmux-config.sh`

8. Create `test/lib/layouts/<name>.bats` with tests for:
   - Function existence
   - Success at pane counts 1, 2, 3, 5
   - Custom ratio (if applicable)
   - Source guard

9. Add balance tests to `test/balance.bats` for pane counts 1-10

10. Add a section to `README.md` with ASCII diagram matching the preview variable

11. Register a keybinding in `tmux-tiling-revamped.tmux` (or document as cycle/picker only)

## Adding a New Operation

1. Create `src/lib/operations/<name>.sh` with source guard and exported function

2. Source in `src/tiling.sh` and add dispatcher case

3. Create `test/lib/operations/<name>.bats`

4. Add integration test in `test/integration.bats`

5. Register keybinding in `tmux-tiling-revamped.tmux`

6. Document in README.md and update help command in `src/tiling.sh`

## Coding Conventions

- Every file has a source guard
- Every public function uses `export -f`
- Constants go in `src/lib/utils/constants.sh`
- Error logging via `log_error "component" "message"`
- tmux operations via helper functions in `tmux-ops.sh`, not direct calls
- Layout re-apply via `_reapply_current_layout`, not duplicated case statements

## Testing

```bash
# All tests (recursive)
bats --recursive test/

# Specific test file
bats test/lib/layouts/dwindle.bats

# Integration tests only (real tmux server)
bats test/integration.bats test/balance.bats

# Shellcheck
shellcheck -x src/lib/**/*.sh tmux-tiling-revamped.tmux src/tiling.sh
```

Every PR must pass the full test suite with 0 failures. New code must have tests for every function, every branch, and every error path.

## Commit Messages

Follow conventional commits: `type(scope): description`

Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore

## Pull Requests

- One logical change per PR
- Include tests
- Update README if user-facing
- Update CHANGELOG.md
- Update help command if adding new commands
