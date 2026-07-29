# Repository Guidelines

## Project Structure & Module Organization

This repository is a Neovim 0.11+ configuration focused on C/C++, Go, Rust, and Python development. `init.lua` is the entry point. Put editor-wide behavior in `lua/core/`: options, keymaps, autocommands, feature toggles, and Lazy.nvim bootstrap logic live there. Keep plugin specifications grouped by purpose in `lua/plugins/`; language-specific LSP and DAP settings belong in `lua/plugins/lsp/`, with per-language files in `lua/plugins/lsp/lang/`. 

Use `after/ftplugin/` for filetype-local Vimscript. Store reusable starter files under `templates/`, custom dictionaries under `spell/`, and VS Code-style snippets in `snippets/snippets/`. Installer logic is split between `install.sh` and `scripts/`; `lazy-lock.json` pins plugin revisions and should change only when plugin versions are intentionally updated.

## Build, Test, and Development Commands

- `./install.sh --help` lists supported installation and feature-disable options.
- `./install.sh --no-plugin-sync` installs prerequisites without modifying installed plugins.
- `nvim --headless "+Lazy! sync" +qa` installs or updates declared plugins.
- `nvim --headless "+Lazy! restore" +qa` restores the versions in `lazy-lock.json`.
- `nvim --headless "+checkhealth" +qa` checks Neovim, provider, and plugin dependencies.

There is no standalone test framework. Validate changed Lua configuration by starting `nvim`, opening a representative filetype, and checking `:messages` and `:checkhealth` for errors.

## Coding Style & Naming Conventions

Write Lua with four-space indentation, trailing commas in multi-line tables, and double-quoted strings where practical. Follow existing module patterns: lowercase filenames such as `colorschemes.lua`, underscore-separated configuration files such as `lua_ls.lua`, and `require("core.options")` module paths. Keep each plugin's configuration close to its Lazy.nvim spec; avoid unrelated reformatting.

Write Bash scripts with `set -euo pipefail`, quote expansions, and keep OS-specific package installation in the appropriate `scripts/install_*.sh` file. Add snippets as `<language>.json` and register them in `snippets/package.json`.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commit-style prefixes, for example `feat: add per-language feature toggles`, `fix: install go`, and `chore: update ui plugin config`. Use a concise imperative subject and an optional scope, such as `feat(lsp): add SQL server settings`.

PRs should explain the user-visible effect, list validation commands run, and call out dependency or `lazy-lock.json` changes. Link related issues when available. Include screenshots or short recordings for UI, theme, or keymap behavior changes.

## Configuration Safety

Do not commit machine-specific paths, credentials, or generated Neovim state. Preserve the lockfile unless the change deliberately updates plugins, and document any new external executable required by a plugin.
