# Modular Configuration and Migration

Select `vim.g.config_preset = "minimal"` or `vim.g.config_preset = "developer"` near the top of `init.lua`. Refine languages and features in the shared `lua/config/user.lua`; put machine-specific differences in the ignored `lua/config/local.lua`. Restart after changes.

```lua
return {
    languages = { python = true, lua = true },
    features = { dap = true, ai = false, copilot = false },
}
```

`minimal` includes editing, search, Git, terminals, explorer, completion, UI, sessions, and Tree-sitter. The shared user configuration also enables Lua for maintaining this configuration with Lua LSP support. `developer` adds C/C++, Go, Rust, and Python. LaTeX, SQL, AI, Copilot, remote development, images, and formula conversion require explicit selection.

Precedence is the `init.lua` preset, shared user configuration, local overrides, then environment variables. Finally, `NVIM_OFFLINE=1` forcibly disables AI, Copilot, and remote development. `NVIM_PROFILE` temporarily overrides the preset; `NVIM_LANGUAGES` replaces the language set; `NVIM_FEATURES=dap,ai,-images` selects features. Legacy `NVIM_ENABLE_LANGS` / `NVIM_DISABLE_LANGS` remain supported for one release, with newer variables taking precedence. Unknown names and values are errors.

## Installation and Updates

Neovim 0.12.4 is required. Inspect the installation plan first:

```sh
./install.sh --profile minimal --dry-run
./install.sh --profile developer --features dap --dry-run
./install.sh --languages python,tex --features formulas
./install.sh --profile developer --no-plugin-sync
```

The installer uses the shared Lua resolver to collect dependencies and saves selections to the local override file. Fonts, Kitty, and formula conversion are installed according to selected features. Installation restores locked plugin revisions by default. `--no-plugin-sync` installs only system dependencies and saves selections. `--restore-lock` remains for compatibility, as do older flags such as `--disable-go`.

Normal startup does not install Mason tools or parsers, or update plugins. A fresh runtime asks before installing plugins; headless startup does not automatically confirm. `:ConfigInstall` invokes the installer after explicit confirmation. `:ConfigInfo` shows effective settings and dependency sources. `:checkhealth config` reports missing plugins, tools, parsers, and trash utilities.

For explicit updates, use `scripts/sync_plugins.sh --restore-lock=0`. Offline bundles use `bin/nvim-offline-update --online`, which backs up plugins, Mason data, and the lockfile before temporarily entering online maintenance mode.

## Keymap Migration

See [Keymap Conventions](keymaps.md) for the four categories, current mappings, plugin audit, and debug mode. The global leader is comma. Language actions use `,l`, closing a buffer uses `,c`, and Hop uses `,j`. `H/L` switch buffers, Enter expands a closed fold, and `gj/gk` and `gJ` retain native behavior.

Prefix a terminal mapping with a count to select its ID, for example `2,th`. IDs remain stable within a session, and each terminal retains its original directory. Switching layouts reuses the same buffer and process. `,ta` toggles all terminals. Sending code asks for an existing terminal ID; cancellation sends nothing, and exited processes are not implicitly restarted.

LSP mappings appear only when a client supports the corresponding capability and are removed when the last supporting client detaches. Each language has one default formatting client: none-ls/Black for Python, gopls for Go, rust-analyzer for Rust, and clangd for C/C++. Set `vim.g.config_autoformat = false` to disable formatting on save.

## Explorer Interaction

The sidebar uses 20% of the editor width and follows editor resizing. When the explorer is the only remaining window across all tabs, Neovim exits normally; unsaved buffers prevent automatic exit. Starting Neovim with directory arguments allows an explorer-only session. Opening the first file closes that startup explorer. Explorers opened later remain sidebars when files are selected.

The Snacks workflow uses `a` to create, `r` to rename, `c` to copy to a destination, `x` to cut, `p` to paste, `y` to copy the path, `H` to show hidden files, `I` to show ignored files, `<BS>` for the parent directory, and `.` to set the selected directory as the root. `Ctrl-x`, `Ctrl-v`, and `Ctrl-t` open horizontal splits, vertical splits, and tabs. These window-local mappings retain their explorer behavior.

`d` moves to trash; `D` permanently deletes. Both require explicit confirmation. Missing `trash` / `gio` executables or failed trash operations never fall back to permanent deletion. An existing destination or a failed cross-device rename preserves the cut source and reports the error. Changing the explorer root does not change the global working directory. Snacks' `Ctrl-c` explicitly changes the current tab's directory.

## Extending Capabilities

Add languages under `languages` in `lua/config/capabilities.lua`, declaring `ft`, `servers`, Mason `tools`, `parsers`, `system`, `format`, `formatter`, and optional `debug`. For example:

```lua
lua = {
    ft = { "lua" }, servers = { "lua_ls" },
    tools = { "lua-language-server", "stylua" }, parsers = { "lua", "luadoc" },
    formatter = "stylua", format = "null-ls",
},
```

Put dedicated plugins in `lua/plugins/languages/` and explicitly include them in `config/specs.lua`. Helpers belong in `lua/modules/`, outside Lazy scanning. Declare platform package names in `scripts/system-packages.lua` when adding system capabilities. Features define their own mappings; which-key displays them.

On macOS, VimTeX reverse search refocuses the terminal. It first checks `vim.g.config_tex_focus_app`, then recognizes `TERM_PROGRAM` values for Kitty, iTerm, Ghostty, WezTerm, Alacritty, Warp, and Terminal, and finally defaults to Kitty. `TERM=xterm-kitty` is also recognized.

Removed plugins include nvim-tree, ToggleTerm, OpenCode, Portal, Harpoon, Grapple, Illuminate, SnipRun, and Telescope's fzf, neoclip, and DAP extensions. Telescope remains a private dependency of the remote feature. Basic Markdown rendering remains; formula conversion requires `formulas`. Sidekick and Copilot are independent, and basic Tab completion does not load AI. Old navigation bookmarks and clipboard/macro history mappings are not retained.

## Offline Distribution and Testing

```sh
scripts/build-offline-bundle.sh --profile minimal --version minimal
scripts/build-offline-bundle.sh --profile developer --features dap --version developer-dap
bash tests/test_offline_bundle.sh dist/nvim-offline-linux-x86_64-minimal.tar.zst
```

The bundle manifest records configuration, plugin revisions, and tools. The target is Ubuntu 24.04 Linux x86_64; project toolchains must still be available on the target machine. Offline mode disables Crates' online index queries. `lite.lua` remains the standalone zero-plugin entry point.

Local tests use `tests/prepare_runtime.py` to build a temporary runtime from installed plugin repositories at locked revisions. Never use the production data directory for tests. `NVIM_LOCKFILE` selects a separate lockfile. Configuration, safety, keymap, and terminal checks are in `tests/test_config.lua`, `tests/test_safety.lua`, `tests/check_keymaps.lua`, and `tests/test_runtime.lua`.
