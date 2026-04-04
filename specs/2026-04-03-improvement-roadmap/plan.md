# Improvement Roadmap

## Competitive Position

tmux-tiling-revamped already leads in layout variety (8 vs tilish's 6), BSP quality (16 orientations, proper dwindle/spiral), and unique features (marks, presets, scratchpads, fzf picker). The main gaps are in workspace management, performance, and power-user features from tiling WMs.

## Feature Comparison Matrix

| Feature | tiling-revamped | tilish | tilit | Gap? |
|---------|:-:|:-:|:-:|------|
| BSP dwindle/spiral | 8+16 orientations | No | No | Lead |
| Layout picker (fzf) | Yes | No | No | Lead |
| Pane marks | Yes | No | No | Lead |
| Scratchpads | Yes | No | No | Lead |
| Presets (save/restore) | Yes | No | No | Lead |
| Workspace switching | No | Alt+0-9 | Alt+0-9 | Gap |
| Move pane to workspace | No | Alt+Shift+0-9 | Alt+Shift+0-9 | Gap |
| Project launcher (fzf) | No | Alt+p | No | Gap |
| App launcher (dmenu) | No | Alt+d | Alt+d | Gap |
| Layout undo | No | No | No | Opportunity |
| Split ratio memory | No | No | No | Opportunity |
| Configurable split ratio | No | No | No | Opportunity |
| tmux-resurrect compat | Partial | No | No | Improve |
| Performance optimization | Basic | Basic | Basic | Improve |
| International keyboards | No | Yes | Yes | Gap |

## Prioritized Improvements

### Tier 1: High Impact, Moderate Effort

#### 1. Layout Undo/Redo
**What:** Store layout history per window. A keybinding reverts to the previous layout state.
**Why:** tmux has `select-layout -o` but it only works for built-in layouts, not custom layout strings. Users frequently lose their arrangement accidentally. No competitor offers this.
**How:** Maintain a stack of layout strings in a tmux window option (`@tiling_revamped_layout_history`). On every layout change, push the current string before applying the new one. Undo pops and re-applies. Limit stack depth to 10 entries.
**Effort:** 1 new operation file, ~80 lines. Updates to every layout apply function to push before changing.

#### 2. Configurable Default Split Ratio
**What:** Allow the initial BSP split to be something other than 50/50. Hyprland calls this `default_split_ratio`.
**Why:** On ultrawide monitors, 50/50 is rarely what users want. A 60/40 or 70/30 first split makes the master pane immediately usable. The master_ratio already exists for main-* layouts but not for BSP.
**How:** New option `@tiling_revamped_split_ratio` (default 50, range 20-80). Modify `_bsp_build` to use this ratio for the first split level only.
**Effort:** ~20 lines in dwindle.sh, new constant, test updates.

#### 3. Workspace Switching (i3-style)
**What:** Alt+1-9 switches to tmux window 1-9. Alt+Shift+1-9 moves the current pane to that window.
**Why:** This is the most-used feature in tilish/tilit. It makes tmux windows behave like i3 workspaces. Users switching from i3 expect this.
**How:** New feature file `features/workspaces.sh`. Register Alt+1-9 bindings in the tmux plugin file when `@tiling_revamped_workspaces` is enabled. Create windows on-demand if they don't exist.
**Effort:** 1 new feature file, ~60 lines. Plugin setup additions.

#### 4. Performance: Batch tmux Commands
**What:** Replace sequential `tmux` subprocess calls with batched commands using semicolons.
**Why:** Each `tmux` call in run-shell spawns a new process. The main-center layout already batches (using the `sed 's/$/ ;/'` pattern). Apply the same to promote, circulate, swap, balance, and other operations that call tmux multiple times.
**How:** Audit each operation for multiple tmux calls. Refactor to use a single `tmux` invocation with semicolons where possible. Measure before/after with `time`.
**Effort:** Incremental refactoring across ~6 operation files.

### Tier 2: Medium Impact, Low-Moderate Effort

#### 5. Project Launcher (fzf)
**What:** A keybinding opens an fzf popup listing project directories. Selecting one creates a new tmux window in that directory with the default layout applied.
**Why:** tilish's most praised feature. Power users work across many project directories and want fast switching.
**How:** New feature file. Configurable project root via `@tiling_revamped_project_dir`. Use `find` or `fd` to list directories. fzf selects. `tmux new-window -c <dir>` creates the workspace.
**Effort:** 1 new feature file, ~50 lines.

#### 6. Smart Split Direction
**What:** Inspired by Hyprland's `smart_split`. New panes split along the longest axis of the current pane automatically, similar to autosplit but as the default behavior for all new panes.
**Why:** The current autosplit operation requires an explicit keybinding. Making it the default split behavior (via a hook on `after-split-window`) removes the need to think about split direction.
**How:** New option `@tiling_revamped_smart_split` (default 0). When enabled, hook `after-split-window` to check pane dimensions and re-orient the split if needed.
**Effort:** ~30 lines in autosplit.sh or a new hook handler.

#### 7. tmux-resurrect Integration
**What:** Store tiling metadata in a format that tmux-resurrect can save/restore. After a restore, automatically re-apply the stored layout.
**How:** tmux-resurrect saves all window options. The layout name is already stored in `@tiling_revamped_layout`. Add a `resurrect` hook that re-applies all stored layouts on session restore. Register a `session-created` hook that checks for stored layouts.
**Effort:** ~40 lines in a new hook handler or integration file.

#### 8. International Keyboard Support
**What:** Configurable Shift+number mappings for non-US keyboards (needed for workspace switching).
**Why:** tilish and tilit both support this. Users with AZERTY, German, Nordic keyboards cannot use Shift+number bindings without remapping.
**How:** New option `@tiling_revamped_shiftnum` that accepts a string of 10 characters representing Shift+1 through Shift+0.
**Effort:** ~15 lines in the plugin setup file.

### Tier 3: Lower Priority, Nice-to-Have

#### 9. Per-Window Default Layout
**What:** Different windows get different default layouts based on window name or index.
**Why:** A "code" window might want dwindle, while a "monitoring" window wants grid. Currently, all new windows get the same default.
**How:** New option `@tiling_revamped_window_rules` accepting a semicolon-separated list of `pattern:layout` pairs. The new-window hook matches the window name against patterns.
**Effort:** ~40 lines in the hook handler.

#### 10. Pane Gap Simulation
**What:** Visual separation between panes using tmux's pane-border-style and margin options.
**Why:** Hyprland and i3-gaps popularized gaps. While tmux cannot do true pixel gaps, wider pane borders with custom colors and the `pane-border-lines` option (double, heavy, simple, number) can approximate the look.
**How:** New option `@tiling_revamped_pane_style` that sets `pane-border-lines`, `pane-border-style`, and `pane-active-border-style` on plugin load.
**Effort:** ~20 lines in the plugin setup file.

#### 11. Layout Annotations in Status Bar
**What:** Show the current layout name and pane count in the tmux status bar.
**Why:** Users lose track of which layout is active, especially after cycling.
**How:** Provide a tmux format string `#{@tiling_revamped_layout}` (already stored). Document how to add it to status-right. Optionally add a helper script that formats it with an icon.
**Effort:** Documentation only. The data is already stored.

#### 12. Floating Pane Toggle
**What:** A keybinding that toggles the focused pane between tiled and floating (popup).
**Why:** tilit offers this (Alt+o). Useful for temporary reference panes.
**How:** Use tmux's `display-popup` to show a floating version of the pane, or `break-pane` + `join-pane` for true floating behavior.
**Effort:** ~40 lines in a new operation file.

### Tier 4: Reliability and Developer Experience

#### 13. Shell Compatibility Matrix
**What:** Test every layout and operation under bash 4.x and 5.x. Add a startup check that verifies bash version and fails fast with a clear message.
**Why:** macOS ships bash 3.2 by default, which breaks `${var^^}` (used in pick-layout preview). Users who forget to `brew install bash` get silent failures.
**How:** Add `_check_bash_version` in plugin setup. Run the test suite under both bash 4 and 5 in CI.
**Effort:** ~15 lines + CI config.

#### 14. Error Recovery for Corrupted Layout State
**What:** Detect when stored layout metadata no longer matches actual pane geometry and self-heal.
**Why:** Panes killed externally, tmux resized during apply, or manual pane manipulation can desync the stored layout from reality. The plugin then re-applies a layout that does not match the current pane count.
**How:** Add `tiling.sh validate` that compares `@tiling_revamped_layout` against actual pane count and geometry. Auto-run on hook if mismatch detected. Fallback: clear stored layout and let the user re-apply.
**Effort:** ~50 lines in a new operation file.

#### 15. Startup Time Budget
**What:** Measure and cap plugin initialization time. Add a CI check that times `tmux-tiling-revamped.tmux` execution.
**Why:** The research shows plugins add ~900ms. Keybinding registration should complete in <100ms.
**How:** Wrap plugin setup in `date +%s%N` measurements. Store baseline. CI fails if exceeded.
**Effort:** ~20 lines + CI integration.

#### 16. Deprecation Strategy for Options
**What:** Define a pattern for renaming or removing tmux options across versions. Deprecated options log a warning for 2 major versions before removal.
**Why:** As the plugin grows, options will evolve. Users need migration guidance, not silent breakage.
**How:** Add `_check_deprecated_options` function that runs on plugin load. Maintains a list of old->new option mappings.
**Effort:** ~30 lines in a new utility file.

#### 17. Fuzz Testing for Layout String Generation
**What:** Generate layout strings for random pane counts and window dimensions, then validate they parse correctly via `tmux select-layout` in the test server.
**Why:** `_bsp_build` and `_main_center_build` produce layout strings with precise pixel coordinates. A single off-by-one breaks the layout silently. Manual tests cover known sizes but not the full input space.
**How:** Integration test that loops over pane counts 2-12 and window dimensions (100x30, 200x50, 300x80). Each combination applies and verifies no error.
**Effort:** ~40 lines in integration tests.

#### 18. Help Command
**What:** Add `tiling.sh help` that prints a concise usage reference with all commands, options, and keybindings.
**Why:** Users in the middle of a session should not need to open a browser. The README is comprehensive but not accessible from the terminal.
**How:** New case in tiling.sh dispatcher. Reads a heredoc or static string.
**Effort:** ~60 lines.

#### 19. Hook Deduplication
**What:** Prevent duplicate hook registration when the user reloads their tmux config.
**Why:** Each `prefix+r` reload appends new hooks without removing old ones. After 5 reloads, every pane split triggers the hook handler 5 times.
**How:** Clear tiling hooks before re-registering them in `tmux-tiling-revamped.tmux`. Use `tmux set-hook -gu` to unset before `set-hook -ga`.
**Effort:** ~10 lines in plugin setup.

#### 20. tmux Version Compatibility Gate
**What:** Check tmux version at plugin load. Disable features that require newer tmux versions gracefully.
**Why:** `display-popup` requires 3.2+. `pane-border-lines` requires 3.3+. Users on older tmux get cryptic errors.
**How:** Add `_check_tmux_version` that parses `tmux -V`. Each feature check gates on a minimum version. Log which features were skipped.
**Effort:** ~30 lines in plugin setup.

### Tier 5: Power User and Ecosystem

#### 21. Pane Minimum Size Guard
**What:** Before applying any layout, check that no pane would shrink below `@tiling_revamped_min_pane_width` (default 10) or `@tiling_revamped_min_pane_height` (default 5). Refuse to apply and log a warning if violated.
**Why:** With many panes, individual panes become invisible or unusable. The layout looks broken and the user does not understand why.
**How:** Pre-check in each layout function before calling `select-layout`. Calculate expected dimensions from pane count and window size.
**Effort:** ~30 lines in a shared utility, called from each layout.

#### 22. Layout-Aware Operation Guards
**What:** Operations that don't apply to the current layout return silently instead of producing visual glitches. `resize-master` on grid/deck does nothing. `balance` on monocle does nothing.
**Why:** Users press keybindings without checking which layout is active. Irrelevant operations should be no-ops, not errors.
**How:** Audit each operation. Add early returns for inapplicable layouts. Most already have this partially.
**Effort:** Incremental, ~5 lines per operation.

#### 23. Orientation Visual Indicator
**What:** Add `tiling.sh info` command that shows: current layout, orientation flags decoded in plain English, pane count, master ratio, and layout history depth.
**Why:** BSP layouts have 16 orientation variants. Users cannot see which one is active. Debugging layout issues requires this visibility.
**How:** New case in tiling.sh dispatcher. Reads stored options and formats output.
**Effort:** ~40 lines.

#### 24. Session-Wide Layout Sync
**What:** Option `@tiling_revamped_sync_all_windows` that applies the current layout to ALL windows when any layout operation is performed.
**Why:** Users who want consistent tiling across their entire session currently must apply layouts per-window.
**How:** After any layout apply, iterate over all windows and re-apply stored layouts. Guard against recursion.
**Effort:** ~30 lines in a wrapper around layout apply functions.

#### 25. Pane Swap with Preview (fzf)
**What:** `tiling.sh swap-pick` opens an fzf popup listing all panes with their current command and working directory. User selects which pane to swap with.
**Why:** Directional swap (U/D/L/R) is blind. With 7+ panes, finding the right target by direction is guesswork.
**How:** Use `tmux list-panes -F` to build a labeled list. fzf selects. `tmux swap-pane` executes.
**Effort:** ~50 lines in a new operation file.

#### 26. Layout Transition Animation
**What:** Option `@tiling_revamped_animate` (default 0) that applies 3-4 intermediate layout strings with small delays to create a visual transition when switching layouts.
**Why:** Purely cosmetic polish. Makes layout changes feel intentional rather than jarring.
**How:** Interpolate between current and target layout strings. Apply each intermediate with 20ms sleep.
**Effort:** ~60 lines in a new utility. High complexity due to coordinate interpolation.

#### 27. Custom Layout DSL
**What:** A mini-language for defining custom layouts: `"H[60:V[50,50],40]"` meaning "horizontal split at 60%, left has vertical 50/50, right is 40%". Users register via `@tiling_revamped_custom_<name>`.
**Why:** Power users want layouts beyond the 8 built-in ones without writing bash.
**How:** DSL parser that generates tmux layout strings. Add to picker, cycle, and presets.
**Effort:** ~150 lines. Most complex feature in the roadmap.

#### 28. Health Check Command
**What:** `tiling.sh doctor` verifies: bash version, fzf version, tmux version, no duplicate hooks, no conflicting plugins, all options accessible.
**Why:** Debugging user issues without visibility into their environment is slow. A single command surfaces all problems.
**How:** New case in dispatcher. Runs each check, outputs pass/fail per item.
**Effort:** ~80 lines.

#### 29. Quiet Mode for Scripting
**What:** Option `@tiling_revamped_quiet` (default 0) that suppresses all `display-message` notifications. Log file still captures everything.
**Why:** Users who script tiling operations (tmuxinator, custom shell scripts) don't want visual noise in the status bar.
**How:** Wrap `tmux display-message` calls in a helper that checks the quiet flag.
**Effort:** ~15 lines + auditing existing display-message calls.

#### 30. Changelog and Semver Releases
**What:** Add CHANGELOG.md following Keep a Changelog format. Tag releases on GitHub with semver. Bump `TILING_REVAMPED_VERSION` constant on each release.
**Why:** The project has a version constant but no release history. Users who pin plugin versions via TPM tags need to know what changed. External contributors need a public record of changes.
**How:** Create CHANGELOG.md from git log. Set up a release workflow.
**Effort:** Documentation + process. No code changes.

#### 31. Contributor Guide
**What:** CONTRIBUTING.md that defines: how to add a new layout (file structure, test template, preview variable, README section, picker integration), how to add a new operation, coding conventions, test/lint/push workflow.
**Why:** The project received an external PR. Clear contribution guidelines reduce review friction and set quality expectations upfront.
**How:** Write the guide based on existing patterns.
**Effort:** Documentation only.

#### 32. Colorblind-Safe Pane Border Defaults
**What:** When the plugin sets pane border styles, default colors must pass WCAG contrast against common terminal backgrounds.
**Why:** The pane gap simulation feature (item 10) will set border colors. Users with color vision deficiency need sufficient contrast.
**How:** Test default colors against dark (#1a1b26, #282c34) and light (#fafafa, #f5f5f5) backgrounds. Document which terminal themes work best.
**Effort:** Research + documentation. ~10 lines of default style configuration.

## Implementation Order

The suggested order maximizes user impact while keeping each change small and shippable. Foundation work comes first.

**Phase 0: Foundation (before any new features)**
- Balance tests for all 8 existing layouts (Gate 2)
- Hook deduplication (#19)
- tmux version compatibility gate (#20)
- Shell compatibility check (#13)

**Phase 1: Core differentiators**
1. Layout undo/redo (#1)
2. Configurable split ratio (#2)
3. Performance batching (#4)

**Phase 2: Competitive parity**
4. Workspace switching (#3)
5. International keyboards (#8)
6. Project launcher (#5)

**Phase 3: Ecosystem**
7. tmux-resurrect integration (#7)
8. Smart split direction (#6)
9. Health check command (#28)
10. Help command (#18)

**Phase 4: Power user**
11. Pane minimum size guard (#21)
12. Error recovery (#14)
13. Pane swap with preview (#25)
14. Custom layout DSL (#27)

**Phase 5: Polish**
15. Per-window layout rules (#9)
16. Pane gap simulation (#10)
17. Floating pane toggle (#12)
18. Layout annotations in status bar (#11)
19. Orientation visual indicator (#23)
20. Layout transition animation (#26)

**Ongoing**
- Deprecation strategy (#16)
- Startup time budget (#15)
- Fuzz testing (#17)
- Quiet mode (#29)
- Changelog and releases (#30)
- Contributor guide (#31)
- Colorblind-safe defaults (#32)
- Layout-aware operation guards (#22)
- Session-wide layout sync (#24)

### CI/CD Pipeline (items 33-50, ordered by implementation phase)

**Phase 6: Automated Releases and Core Pipeline**

| # | Item | Description |
|---|------|-------------|
| 33 | Automated semantic releases | Parse conventional commits since last tag, bump version in constants.sh, generate CHANGELOG entry, commit, tag, create GitHub release. Runs after all tests pass on main. |
| 34 | Dependency caching | Cache Homebrew/apt downloads between CI runs to cut macOS job time. |
| 35 | Concurrent workflow cancellation | Cancel in-progress CI runs when a new push arrives to the same branch. |
| 36 | Job dependency optimization | Lint and unit tests in parallel. Integration tests after lint. Release after all pass. |
| 37 | GitHub Actions permissions hardening | `permissions: read-all` at top, specific writes only where needed. |
| 38 | Pin actions to SHA hashes | `actions/checkout@<sha>` instead of `@v6`. Prevent supply chain attacks. |
| 39 | Workflow dispatch for manual releases | `workflow_dispatch` trigger with version input for manual release override. |
| 40 | Bats version pinning | Pin bats-core version in CI instead of latest. |

**Phase 7: Quality Gates**

| # | Item | Description |
|---|------|-------------|
| 41 | Shellcheck strict mode | Upgrade to `--severity=info`. |
| 42 | Commit message linting | Validate conventional commit format on push via grep. |
| 43 | Startup time measurement | Time `tmux-tiling-revamped.tmux` execution, fail if >200ms. |
| 44 | Test coverage tracking | Count @test declarations vs export -f functions, report ratio. |
| 45 | Test execution time guard | Fail if suite exceeds 10 minutes. |
| 46 | Test output noise detection | Fail if tests print unexpected stderr. |
| 47 | Test flakiness detection | Run suite 3 times, flag tests that pass/fail inconsistently. |
| 48 | Parallel test execution | `bats --jobs 4` for multi-core runners. |
| 49 | Draft PR detection | Skip expensive jobs (integration, balance) for draft PRs. |
| 50 | PR title conventional commit validation | Verify PR title format for auto-release notes. |

**Phase 8: Code Consistency Checks**

| # | Item | Description |
|---|------|-------------|
| 51 | Duplicate code detection | Find repeated >10-line blocks across source files. |
| 52 | File size guard | Fail if any source file exceeds 300 lines. |
| 53 | Test naming convention check | Verify @test descriptions follow `"filename.sh - description"` pattern. |
| 54 | Unused export detection | Verify each `export -f` is called from another file. |
| 55 | Source guard completeness check | Every .sh in src/lib/ has a guard, and helpers.bash has a corresponding unset. |
| 56 | ASCII art width validation | Verify all TILING_PREVIEW_* have consistent line widths. |
| 57 | Makefile target validation | Run every Makefile target in CI. |
| 58 | Shebang check | Verify every .sh file starts with `#!/usr/bin/env bash`. |
| 59 | Dead code detection | Find functions never called, not exported, not in dispatcher. |
| 60 | Constants exhaustiveness check | Every `@tiling_revamped_*` literal has a `readonly OPT_*` in constants.sh. |

**Phase 9: Cross-Referencing and Sync**

| # | Item | Description |
|---|------|-------------|
| 61 | README-to-code sync check | Every CLI command in README exists in dispatcher, and vice versa. |
| 62 | Help text sync check | Help heredoc lists every dispatcher command. |
| 63 | TILING_PREVIEW presence check | Every layout module exports a preview variable and appears in PICK_LAYOUTS. |
| 64 | Hook registration audit | Every `_bind` call references a command in the dispatcher. |
| 65 | Version consistency check | Version in constants.sh, CHANGELOG.md, and README badge must match. |
| 66 | CHANGELOG format validation | Sections must be Added, Changed, Fixed, Removed per Keep a Changelog. |
| 67 | CHANGELOG link verification | Every PR reference (#N) resolves to a real PR. |
| 68 | CONTRIBUTING.md accuracy check | File structure described in CONTRIBUTING matches actual repo. |
| 69 | Integration test completeness matrix | Every dispatcher command has at least one integration test. |
| 70 | Shellcheck directive audit | Every `# shellcheck disable=` has a justification comment. |

**Phase 10: Testing and Compatibility Matrix**

| # | Item | Description |
|---|------|-------------|
| 71 | Matrix testing across tmux versions | Test against tmux 3.2, 3.4, 3.6. |
| 72 | Matrix testing across bash versions | Test bash 4.0 and 5.x explicitly. |
| 73 | Multi-arch testing | Test on x86_64 and ARM64 runners. |
| 74 | Minimum tmux version regression test | Build tmux 3.2 from source in CI. |
| 75 | Test isolation verification | Run each test file individually, compare against recursive run. |
| 76 | Fuzz testing for layout strings | Loop pane counts 2-12 across window dimensions. |
| 77 | tmux server leak detection | Verify no /tmp/tiling-test-* sockets remain after tests. |

### GitHub Templates and Community Health Files (items 78-100)

**Phase 11: Issue and PR Templates**

| # | Item | Description |
|---|------|-------------|
| 78 | Bug report issue form | `.github/ISSUE_TEMPLATE/bug-report.yml` with structured fields: tmux version, bash version, OS, terminal, steps to reproduce, expected/actual behavior, `tiling.sh doctor` output, layout, pane count. Required fields enforced. Auto-labels `bug`. |
| 79 | Feature request issue form | `.github/ISSUE_TEMPLATE/feature-request.yml` with fields: problem, proposed solution, alternatives, affected layout/operation, willingness to PR. Auto-labels `enhancement`. |
| 80 | Documentation issue form | `.github/ISSUE_TEMPLATE/docs.yml` for README errors, missing docs. Fields: section, current text, suggested fix. Auto-labels `documentation`. |
| 81 | Question/support issue form | `.github/ISSUE_TEMPLATE/question.yml` for usage questions. Links to README and existing issues. Auto-labels `question`. |
| 82 | Issue template config | `.github/ISSUE_TEMPLATE/config.yml` with external links, optionally disables blank issues. |
| 83 | Pull request template | `.github/PULL_REQUEST_TEMPLATE.md` with checklist: description, type, testing, CHANGELOG, README, make test, make lint, screenshots. |

**Phase 12: Community Health Files**

| # | Item | Description |
|---|------|-------------|
| 84 | CODEOWNERS | `.github/CODEOWNERS` requiring @gufranco review for all changes. Extra protection for plugin entry point, CI workflows, and BSP core. |
| 85 | SECURITY.md | Responsible disclosure policy, supported versions, response time SLA (48h), what qualifies as security issue. |
| 86 | FUNDING.yml | `.github/FUNDING.yml` with GitHub Sponsors structure. |
| 87 | CODE_OF_CONDUCT.md | Contributor Covenant v2.1. |
| 88 | .gitattributes | `* text=auto` to enforce text files, prevent binary commits. |

**Phase 13: Automation Workflows**

| # | Item | Description |
|---|------|-------------|
| 89 | Stale issue/PR bot | Mark issues with no activity for 30 days as stale, close after 7 more. Exempt `pinned`, `security`, `bug`. |
| 90 | Auto-labeler | `.github/labeler.yml` with path-based rules for layouts, operations, tests, ci, docs. |
| 91 | Dependabot config | `.github/dependabot.yml` for GitHub Actions version updates (weekly). |
| 92 | PR size labeling | Auto-label PRs: size/S (<100), size/M (100-400), size/L (400-1000), size/XL (>1000). |
| 93 | Issue auto-assignment | Auto-assign new issues to @gufranco. |
| 94 | Contributor stats tracking | Monthly workflow generating CONTRIBUTORS.md from git shortlog. |
| 95 | Release announcement | Create GitHub Discussion post for each release with changelog. |

**Phase 14: Advanced Governance**

| # | Item | Description |
|---|------|-------------|
| 96 | Markdown lint | Run markdownlint on README, CHANGELOG, CONTRIBUTING. Project dictionary for domain terms. |
| 97 | Spell check | Run typos or cspell on docs and code comments. |
| 98 | YAML lint | Run yamllint on all YAML files (templates, workflows, configs). |
| 99 | Workflow syntax validation | Run actionlint on all workflow files. |
| 100 | Shellcheck SARIF upload | Convert shellcheck to SARIF, upload to GitHub Code Scanning. |
| 101 | Test result JUnit upload | Convert bats TAP to JUnit XML, display in PR checks UI. |
| 102 | TODO/FIXME audit | List all TODO/FIXME in annotations without failing build. |
| 103 | Trailing whitespace/EOF check | Verify all files via editorconfig-checker. |
| 104 | License compliance scan | Scan for incompatible license headers or known code fingerprints. |
| 105 | Repo settings audit | Weekly workflow verifying: default branch, delete-on-merge, squash default, branch protection active. |
| 106 | Community profile score check | Verify all health files present via `gh api` community profile endpoint. |
| 107 | Changelog entry enforcement on PRs | Fail PR CI if CHANGELOG not modified (exempt ci/chore/deps labels). |
| 108 | Single commit per PR warning | Warn if PR has >5 commits. |
| 109 | GPG commit signing recommendation | Informational annotation for unsigned commits. |
| 110 | Release notes quality check | Verify release notes have content, no empty sections. |
| 111 | Nightly full regression | Scheduled nightly run of full suite on latest main. |
| 112 | Workflow run time trending | Store execution time per run, warn if 20%+ increase over 10-run average. |
| 113 | GitHub Discussions enable | Enable Discussions with Q&A, Ideas, Announcements categories. |
| 114 | Branch protection via CI | Setup workflow configuring: require status checks, linear history, no force push to main. |
| 115 | Release asset attachment | Attach .tar.gz of plugin source (excluding tests/specs/CI) to each release. |
| 116 | Issue response time SLA | Daily check for issues without response >48h, auto-comment and label `needs-triage`. |
| 117 | Deprecation notice automation | When deprecation.sh is updated, post summary in next release notes. |
| 118 | PR auto-merge config | Enable auto-merge for PRs passing all checks with approval. |
| 119 | Repository topics sync | CI verifies repo topics match canonical list. |
| 120 | Cache audit | Monthly workflow deleting caches older than 7 days. |

## Implementation Order (Updated)

The suggested order maximizes user impact while keeping each change small and shippable. Foundation work comes first.

**Phase 0: Foundation (DONE)**
- Balance tests for all 8 existing layouts
- Hook deduplication
- tmux version compatibility gate
- Shell compatibility check

**Phase 1: Core differentiators (DONE)**
1. Layout undo/redo
2. Configurable split ratio
3. Performance batching

**Phase 2: Competitive parity (DONE)**
4. Workspace switching
5. International keyboards
6. Project launcher

**Phase 3: Ecosystem (DONE)**
7. tmux-resurrect integration
8. Smart split direction
9. Health check command
10. Help command

**Phase 4: Power user (DONE)**
11. Pane minimum size guard
12. Error recovery
13. Pane swap with preview
14. Custom layout DSL

**Phase 5: Polish (DONE)**
15-20. Per-window rules, gaps, floating, status bar, orientation, animation

**Phase 6: Automated releases and core pipeline**
33-40. Semantic releases, caching, concurrency, job optimization, permissions, SHA pinning

**Phase 7: Quality gates**
41-50. Shellcheck strict, commit lint, startup time, coverage, flakiness, parallel tests

**Phase 8: Code consistency checks**
51-60. Duplicate detection, file size, naming, unused exports, source guards, ASCII art validation

**Phase 9: Cross-referencing and sync**
61-70. README sync, help sync, preview sync, hook audit, version check, CHANGELOG validation

**Phase 10: Testing and compatibility matrix**
71-77. tmux version matrix, bash matrix, multi-arch, minimum version, isolation, fuzz, leak detection

**Phase 11: Issue and PR templates**
78-83. Bug report, feature request, docs issue, question, config, PR template

**Phase 12: Community health files**
84-88. CODEOWNERS, SECURITY.md, FUNDING.yml, CODE_OF_CONDUCT.md, .gitattributes

**Phase 13: Automation workflows**
89-95. Stale bot, auto-labeler, dependabot, PR size labels, auto-assign, contributors, release announcements

**Phase 14: Advanced governance**
96-120. Markdown lint, spell check, YAML lint, actionlint, SARIF, JUnit, TODO audit, license scan, repo audit, community score, nightly regression, time trending, discussions, branch protection, release assets, SLA, deprecation, auto-merge, topics sync, cache audit

**Ongoing**
- Deprecation strategy (#16)
- Startup time budget (#15)
- Fuzz testing (#17)
- Quiet mode (#29)
- Colorblind-safe defaults (#32)
- Layout-aware operation guards (#22)
- Session-wide layout sync (#24)

## Gate 1: Test Coverage (100%)

Every new file and every modified file must reach 100% test coverage across statements, branches, and functions. No exceptions. This applies to unit tests (bats mocks) AND integration tests (real tmux server).

For each feature:
- Every exported function has a dedicated test
- Every code branch (if/else/case) has a test that exercises it
- Every error path has a test that triggers it
- Every edge case (0 panes, 1 pane, empty input, invalid input) has a test
- Integration tests verify the feature works end-to-end in a real tmux session
- No feature is declared complete until `bats test/` passes with zero failures and zero untested paths

## Gate 2: Layout Balance Invariant

Every layout that distributes panes across multiple columns or rows must be balanced. "Balanced" means no column or row has more than 1 pane difference from any other column or row in the same zone.

| Layout | Balance rule |
|--------|-------------|
| main-center | Left and right columns differ by at most 1 pane |
| main-vertical | Stack panes have equal height (tmux built-in handles this) |
| main-horizontal | Stack panes have equal width (tmux built-in handles this) |
| grid | Rows differ by at most 1 pane (tmux tiled handles this) |
| dwindle/spiral | Each BSP split divides space evenly (by design) |
| deck | All panes have equal width (tmux even-horizontal handles this) |
| monocle | Single pane, not applicable |

Integration tests must verify balance for every layout at pane counts from 2 up to the maximum the test tmux server can create (limited by terminal dimensions, typically 10-12 in a 200x50 window). The test asserts: for each zone (left column, right column, top row, bottom row), the pane count difference between zones is at most 1.

Required test matrix per layout:

| Pane count | What to verify |
|------------|---------------|
| 1 | Layout applies without error, single pane fills window |
| 2 | Two-pane split at correct ratio |
| 3 | First secondary split, zones balanced |
| 4-6 | Distribution stays balanced as panes increase |
| 7-9 | Balance holds under higher counts |
| 10+ | Maximum pane count the terminal supports, no crash, balance maintained |

The balance invariant must hold at every pane count, not just sampled values. If a layout works at 5 panes but breaks at 6, that is a bug.

This applies to ALL existing layouts, not just new ones. Every layout in the project must have balance verification tests across the full pane count range. Existing layouts that lack these tests must have them added as part of this roadmap before any new features are implemented. Fixing the foundation comes first.

## Gate 3: Clean Room Verification

Features inspired by tilish/tilit/Hyprland must follow clean room implementation. Abstract the concept, close the reference, implement independently. See `rules/clean-room.md`.
