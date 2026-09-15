# Keymap Conventions

The leader is comma. `,c` means comma followed by c; `Ctrl-j` means pressing the keys together. The two-key limit applies to action entry points, excluding subsequent input such as search text, Hop target characters, or surround objects.

## Four Categories

1. Preserve native commands such as `Ctrl-w`, `za`, `gj/gk`, `gJ`, search, text objects, and macros. Deliberate shortcuts include `H/L` for buffers, Enter to expand folds, `Ctrl-h/j/k/l` for windows, insert-mode `jk` to escape, and visual `J/K` to move selections and `p` to preserve the register. Existing accelerated `j/k` movement remains.
2. Frequent actions use at most two keys. An action must not also be a prefix for longer mappings.
3. Common actions use intuitive groups discoverable through which-key. Language-specific actions are limited to their filetypes.
4. Installation, maintenance, and rarely used actions primarily use command completion. Configuration checks live under `,x`. Not every plugin API needs a mapping.

## Frequent Actions

| Keys | Action |
| --- | --- |
| `,w` / `,e` | Save, retrying with SudaWrite on failure / reload |
| `,c` | Close buffer; Snacks preserves window layout and handles unsaved-buffer confirmation when available |
| `,f` / `,F` | Smart file search / project text search |
| `,n` / `,b` | Explorer / buffer picker |
| `H` / `L` | Previous / next buffer |
| `[b` / `]b` | Alternative previous / next buffer mappings |
| Enter | Expand the closed fold under the cursor; otherwise keep native Enter behavior |
| `,j` | Hop two-character jump in normal, visual, and operator-pending modes |
| `,o` | Symbol outline |
| `,h` | Clear search highlights |
| `,q` / `,Q` | Save and close window / save and quit all |
| `gd` | Go to definition when supported by LSP |
| `Ctrl-h/j/k/l` | Switch windows |
| `Alt-Arrow` | Repeatedly resize windows |
| `Ctrl-\` | Toggle terminal in normal and terminal modes |

Neovim's native LSP and diagnostic mappings, including `K`, `gr…`, and `[d/]d`, retain their defaults. The `,l` group provides discoverable language actions. Explorer, picker, and other dedicated plugin windows retain their local mappings.

Folding uses UFO with a high `foldlevel` so leaving insert mode does not close manually opened folds. `zR` and `zM` keep their open-all/close-all meaning through UFO's APIs without lowering that level. Markdown starts with section folds closed, but a single outer heading is excluded from folding: a document with one H1 and several H2 headings remains visible at the H2 level, even after `zM`. Multiple outer headings remain foldable. This uses the Markdown syntax tree, so headings inside fenced code blocks do not count. Without a Markdown parser, the existing indentation fallback remains available.

## Common Groups

All abbreviations in the second column require a leading comma: `ld` means `,ld`.

| Group | Actions |
| --- | --- |
| `,s` Search | `sg` project text, `sw` word/selection, `sb` buffer lines, `ss` document symbols, `sr` replace, `sd` diagnostics, `su` undo history, `sh` help, `sk` keymaps, `sc` command history |
| `,l` Language | `ld` definition, `lR` references, `lh` hover, `ln` rename, `lc` code action, `lf` format, `lo` outline, `lj/ls` join/split code structures |
| `,l` Filetype actions | `lr/lt/lb` run/test/build; Go `lae/lat/las` error handling/tags/fill struct and `lk` documentation; Rust `laa/lam/lk` actions/expand macro/documentation; TeX `lb/lr/lat` compile/PDF/contents; CSV and SQL `lv` open their interfaces |
| `,g` Git | `gn/gN` next/previous hunk, `gs` stage hunk or selected lines, `gu` undo staging, `gS` stage buffer, `gp` preview, `gb` blame, `gd` diff, `gm` repeated review |
| `,p` Sessions | `pl/ps/pd/pc` load/save/delete/load current directory |
| `,t` Terminal | `th/tv/tf/tt` horizontal/vertical/float/tab, `ta` toggle all, `tc` send line, visual `tl/ts` send whole lines/exact selection |
| `,a` AI | `aa` interface, `as` select, `af` send file, visual `av` send selection, `ap` prompt |
| `,u` UI | `uw` toggle wrapping mode |
| `,x` Other and maintenance | `xi` configuration info, `xh` configuration health |

In `Cargo.toml`, `,lau` upgrades the current dependency and `,lah` opens its documentation. Filetype changes remove inapplicable mappings. LSP mappings are removed when their supporting capabilities disappear.

## Debugging and Repeated Actions

Hydra uses its pre-refactor locked revision; other plugin versions are unchanged. which-key's looping menu suits repeated menu actions. Hydra suits debugging because short keys must remain available while navigating source code and must follow the session lifecycle.

With DAP enabled, `,dc` starts or continues debugging. Successful initialization enters debug mode automatically; cancelling startup does not. Use `,dm` to enter without running an existing session. Escape leaves short-key mode without terminating debugging. Subsequent breakpoint stops do not silently reactivate it; use `,dc` or `,dm` again.

| Full mapping | In debug mode | Action |
| --- | --- | --- |
| `,dc` | `c` | Continue |
| `,dn` | `n` | Step over (next) |
| `,ds` | `s` | Step into |
| `,do` | `o` | Step out |
| `,db` | `b` | Toggle breakpoint |
| `,dq` | `q` | Terminate and exit mode |
| `,dm` | Escape to leave | Enter mode without running |

Other actions: `,dB` conditional breakpoint, `,dr` run last, `,dR` REPL, `,du` debug UI, and `,de` evaluation, including visual selections.

A persistent bottom hint lists short keys. Movement, buffer and window navigation, and scrolling remain available. `n/s/o/c/b/q` temporarily change meaning; press Escape before using their native editing, search, or macro functions. Insert, visual, operator-pending, or command-line mode exits debug mode, as does entering a terminal, floating window, or plugin window. Termination, program exit, disconnect, and abnormal closure after initialization clean up the mode. Initialization while focused on a plugin window does not activate short keys; return to source and use `,dm`.

Git's `,gm` opens a looping which-key menu for repeated `n/N/p/s/u` navigation, preview, staging, and undo staging. Escape closes it. This entry requires the UI feature. Window resizing already uses `Alt-Arrow` and needs no additional mode. Explorer, search, database, AI, and DAP UI windows keep their internal controls. Run/build/test workflows mix editing, input, and asynchronous terminals, so they do not automatically create persistent modes.

## Plugin Keymap Audit

| Plugins | Policy |
| --- | --- |
| surround, repeat, matchup, gx, accelerated movement | Preserve editing extensions such as `ys/ds/cs`, `.`, `%`, `gx`, and `j/k`; no management mappings |
| Hop, treesj, outline | Explicit entries; treesj defaults are disabled to preserve native `gJ` |
| Go, VimTeX | Default mappings disabled; filetype-local `,l` mappings take over; VimTeX insert abbreviations are also disabled |
| Rust, Crates, CSV, SQL | Scope mappings to filetypes or Cargo files; dedicated interfaces retain local controls |
| blink.cmp | Default completion controls, with Tab/Shift-Tab for snippet navigation and fallback |
| Copilot | Insert-mode Alt-l accepts, Alt-[/] selects previous/next, and Alt-e dismisses; unused word/line acceptance disabled, panel disabled |
| Snacks, GrugFar, DAP UI, Sidekick, session picker, dbee, Outline | Global entries follow the categories; dedicated windows retain their own interactions |
| wrapping | Default mappings disabled; use `,uw` |
| Mason, Tree-sitter installation, themes, Hex, Suda, Remote | Command completion, including `:Mason`, `:TSInstall`, `:colorscheme`, `:HexToggle`, `:SudaRead`, and `:RemoteStart` |
| VimTeX maintenance | Commands such as `:VimtexInfo` and `:VimtexClean`, without common language mappings |
| OSC52, lastplace, autopairs, esqueleto, ufo, bufferline, lualine, noice, colorizer, bufresize, context display, Markdown rendering, none-ls | Automatic behavior or native commands; no extra mappings for configuration or installation APIs |

## Migration

The `,c…` language group and former Space-prefixed language mappings move to `,l…`. References use `,lR`; running uses `,lr`. The `,b…` group is removed: `,b` selects, `,c` closes, and `H/L` or `[b/]b` switch buffers. Enter expands closed folds. Native `gj/gk` display-line movement and `gJ` joining without spaces are restored. Hop moves from `,m` / `,sj` to `,j`. Configuration checks move from `,ui/uh` to `,xi/xh`. Debug stepping changes from `,di/do/dO` to `,ds/dn/do`, matching the short keys.

Validation covers core/plugin prefix conflicts, language combinations, LSP capability removal, and real Hydra activation, stepping, exit, and mapping restoration without requiring debug adapters.
