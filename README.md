# Modular Neovim Configuration

Targets Neovim 0.12.4. The default `minimal` preset provides editing, Snacks search/explorer/terminal, Git, Blink completion, Tree-sitter, and UI plugins. `developer` additionally enables C/C++, Go, Rust, and Python.

```sh
./install.sh --profile minimal --dry-run
./install.sh --profile developer --features dap
```

Shared settings live in `lua/config/user.lua`; machine-specific overrides belong in the ignored `lua/config/local.lua`. Restart after changing features. Use `:ConfigInfo` to inspect effective settings, `:ConfigInstall` to install selected capabilities, and `:checkhealth config` to check dependencies.

See [Configuration and Migration](docs/modular-config.md) for details. AI, Copilot, LaTeX, databases, remote development, images, and formula conversion are disabled by default.

Keymaps follow four categories: native commands, frequent actions, grouped actions, and maintenance commands. See [Keymaps and Debug Mode](docs/keymaps.md).

Controlled startup and first-use measurements are recorded in [Performance Baseline](docs/performance-baseline.md).

## Standalone Lite Mode

`nvim -u /path/to/lite.lua` starts the zero-plugin configuration for temporary servers. Validate it with `bash tests/test_lite.sh`.

## Standalone Offline Configuration

Copy [`single-config.lua`](single-config.lua) to any machine with Neovim **0.12.4 or newer**:

```sh
nvim -u /path/to/single-config.lua
# Or: nvim --clean -u /path/to/single-config.lua
```

This entry point reads no other repository files and loads no installed plugins, user configuration, or project-local configuration. It uses built-in netrw, comments, LSP, completion, snippets, and diff, then adds a floating picker, terminal switching, Git inspection, and project sessions. No Nerd Font is required. `init.lua` and the smaller `lite.lua` remain independent.

The Leader key remains comma. Use `:SingleHelp`, `,sk`, `:SingleHealth`, or `,xh`; editable settings are at the top of the file.

| Common action | Keymap / command |
| --- | --- |
| Save, close buffer, quit | `,w`, `,c`, `,Q` |
| Explore directories, find files, switch buffers | `,n`, `,f`, `,b` |
| Recent files, current file lines | `,so`, `,sb` |
| Project search, word search, repeat search | `,F` / `,sg`, `,sw`, `,sR` |
| Confirm project replacement | `,sr`; changes stay in buffers until saved |
| Previous / next quickfix item | `[q`, `]q` |
| Document outline, workspace symbols, diagnostics | `,o` / `,ss`, `,sS`, `,sd` |
| Definition, references, docs, rename, code actions | `gd` / `,ld`, `,lR`, `,lh`, `,ln`, `,lc` |
| Format, toggle format on save | `,lf`, `,lF`; off by default |
| Run, build, test | `,lr`, `,lb`, `,lt` |
| Horizontal / vertical / floating / tab terminal | `,th`, `,tv`, `,tf`, `,tt`; prefix a number to select a terminal |
| Toggle terminal, all terminals, leave terminal input | `Ctrl-\`, `,ta`, double `Esc` |
| Send line / selection to a terminal | `,tc`, `,tl` / `,ts` in visual mode; sends a trailing newline |
| Git status, log, branches, blame, file diff | `,gg`, `,gl`, `,gB`, `,gb`, `,gd` |
| Jump between diff hunks | `,gn` / `]c`, `,gN` / `[c` |
| Save / load / delete project session | `,ps`, `,pl` / `,pc`, `,pd` |
| Built-in snippets, surround selection | `,li`, `,lz` in characterwise visual mode |
| Word / path / omnifunc completion | `Ctrl-n`, `Ctrl-x Ctrl-f`, `Ctrl-x Ctrl-o` |
| Comments, folds, matching pairs | Built-in `gcc` / `gc`, `za` / `zR` / `zM`, `%` |
| Copy the last register with OSC52 | `,xy`; requires terminal support |

In a picker, type to filter, use `Ctrl-n` / `Ctrl-p` to move, Enter to open, `Ctrl-x` / `Ctrl-v` to split, `Ctrl-q` to send jumpable results to quickfix, and `Esc` to cancel. Use `:SingleFiles`, `:SingleGrep text`, and `:SingleCancel` for file search, text search, and cancellation.

### External tools and offline fallbacks

| Capability | When available | When missing |
| --- | --- | --- |
| File / text search | Uses rg and follows `.gitignore` | Lua directory walk; does not parse `.gitignore` |
| Language servers | Detects clangd, gopls, rust-analyzer, pyright-langserver, lua-language-server, bash-language-server | Editing, word/path completion, and indent folding remain available |
| Git | Status, log, blame, and current-buffer vs HEAD diff | Reports the missing executable when called |
| Run and test | C/C++: CMake and CTest; Go: go; Rust: cargo; Python: python3 and unittest; Shell: bash | Reports missing tools; use the terminal or `:make` |
| Clipboard | System provider or explicit OSC52 copy | Ordinary registers |
| Persistent undo and sessions | Stored in `stdpath("state")/single-config/` | Disabled when unwritable; editing remains available |

The configuration never installs tools or downloads plugins. Go tasks and gopls disable module and toolchain downloads; Rust tasks use `--offline`, and rust-analyzer receives offline environment variables. Prepare build dependencies beforehand. CMake uses the existing `build` directory and does not configure the project.

Search uses **literal matching with smart case**: queries containing uppercase characters are case-sensitive. Both search paths skip `.git`, `node_modules`, `target`, and `build`, and do not follow directory symlinks. Text search skips binary files and files larger than 1 MiB. Lua scanning is capped at 20,000 files, results at 5,000 matches, and rg output at 16 MiB. The project root is the nearest language marker or `.git`, falling back to the current working directory.

Sessions manually save and restore file windows only. Running terminals and unsaved file contents are not saved. No resources outside the state directory are required.

To support remote environments with low file-descriptor limits, LSP does not register recursive workspace watchers. Open-file changes still synchronize normally. Restart Neovim if a language server does not reflect bulk external changes.

### Differences from the plugin configuration and validation

The built-in implementation preserves common editing and development workflows but does not provide a full DAP UI, AI, image rendering, database UI, Git hunk staging, or extra Tree-sitter parsers. The Git branch list is read-only. Undo and command history use native lists; auto-pairs and surround use simple rules without syntax analysis. Formatting depends on language-server support; pyright itself does not format.

```sh
python3 tests/test_single_config.py
bash tests/test_lite.sh
```

The single-file test copies the configuration into a temporary directory and verifies tool-free fallbacks, special paths, cancellation and limits, window lifecycles, terminal reuse, editing, sessions, and unwritable state directories. When available, rg, Git, clangd, and gopls integrations are also tested. Development validation used Neovim 0.12.5; 0.12.4 was not tested separately.

## Offline Bundles

```sh
scripts/build-offline-bundle.sh --profile minimal --version minimal
scripts/build-offline-bundle.sh --profile developer --features dap --version developer-dap
bash tests/test_offline_bundle.sh dist/nvim-offline-linux-x86_64-minimal.tar.zst
```

Extract the archive and run `bin/nvim-offline`. Installation and updates are disabled by default, and AI/Copilot are forcibly disabled. Use `bin/nvim-offline-update --online` for explicit online updates; it creates a backup first.

## Layout

- `lua/core/`: editor options, keymaps, shared events, and Lazy bootstrap.
- `lua/config/`: configuration resolution, capability catalog, plugin selection, installation, and health checks.
- `lua/plugins/`: Lazy specifications grouped by purpose, with language specifications under `languages/`.
- `lua/modules/`: terminal, explorer, LSP, and other helpers.
- `scripts/`: installation and offline distribution driven by the shared resolver.
- `tests/`: isolated runtime, configuration, keymap, terminal, safety, and offline checks.
