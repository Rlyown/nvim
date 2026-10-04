# Neovim Configuration

A Neovim 0.12.4+ development setup with completion, search, Git, terminal, Tree-sitter, LSP, formatting, debugging, and optional AI. The installer installs the selected system dependencies, plugins, Tree-sitter parsers, and Mason tools.

## Quick install

Install Neovim 0.12.4+ first. On macOS, install Homebrew as well. Then clone the configuration and install the full non-LaTeX setup:

```sh
git clone git@github.com:Rlyown/nvim.git ~/.config/nvim
cd ~/.config/nvim
./install.sh --full
```

The full setup includes C/C++, Go, Rust, Python, Lua, Shell, web languages, JSON/YAML/TOML/XML, Docker, Assembly, CSV, SQL, and Markdown. It also enables debugging, AI, remote development, image support, and their dependencies. The installer needs an internet connection. Once it finishes, start Neovim with `nvim`.

To install the saved local selection, run:

```sh
./install.sh
```

On a fresh install with no saved selection, this starts an interactive wizard. Choose Full, Developer, Minimal, or Custom. The wizard saves your selection after installation. Use `./install.sh --full` to skip the wizard and install the full setup directly.

Preview the installation plan without making changes:

```sh
./install.sh --dry-run
```

Use `./install.sh --help` for the short option list. Add `--no-plugin-sync` to install system packages without syncing plugins.

## Profiles and exclusions

- `minimal` provides the editor, completion, Tree-sitter, search, file browsing, Git, terminal, sessions, and UI plugins.
- `developer` adds C/C++, Go, Rust, and Python development tools.
- `--full` enables all available non-LaTeX languages and development features.
- Use `--languages ...` and `--features ...` for a custom selection. See [Configuration](docs/modular-config.md).

The recommended full setup excludes LaTeX. It does not install TeX Live, MacTeX, latexmk, texlab, or vimtex. The Copilot plugin has been removed. AI features use a separate plugin and may require service credentials.

## After installation

Start Neovim and run `:checkhealth` for Neovim and plugin checks, or `:checkhealth config` for this configuration's dependencies. Run `:ConfigInfo` to inspect the active selection. Run `:ConfigInstall` to install its plugins, parsers, and Mason tools again. The installer saves machine-specific selections in the ignored file `lua/config/local.lua`.

## Other entry points

- [Keymaps](docs/keymaps.md)
- [Configuration and migration](docs/modular-config.md)
- [Performance baseline](docs/performance-baseline.md)
- `nvim -u ./lite.lua` starts the zero-plugin lite mode.
- `nvim -u ./single-config.lua` starts a standalone configuration that does not depend on this repository or plugins.
- See [offline bundle instructions](scripts/build-offline-bundle.sh) to build a package for offline use.
