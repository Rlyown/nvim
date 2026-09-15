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
