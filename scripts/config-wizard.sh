#!/usr/bin/env bash

nvim_config_wizard() {
  local choice answer name
  printf '%s\n' \
    'No saved Neovim selection was found. Choose a setup:' \
    '  1) Full: all languages and optional features (recommended)' \
    '  2) Developer: C/C++, Go, Rust, Python, and Lua' \
    '  3) Minimal: core editor features only' \
    '  4) Custom: choose languages and optional features'
  while true; do
    read -r -p 'Selection [1-4]: ' choice || { echo 'Setup selection cancelled.' >&2; return 1; }
    case "$choice" in
      1)
        export NVIM_PROFILE=developer
        export NVIM_LANGUAGES=cpp,go,rust,python,lua,shell,web,data,docker,asm,csv,sql,markdown,tex
        export NVIM_FEATURES=dap,ai,remote,images,fonts,kitty,-formulas
        break ;;
      2) export NVIM_PROFILE=developer; break ;;
      3) export NVIM_PROFILE=minimal; break ;;
      4)
        export NVIM_PROFILE=minimal
        local languages=''
        for name in cpp go rust python lua shell web data docker asm csv sql markdown tex; do
          answer=''
          read -r -p "Enable $name? [y/N] " answer || { echo 'Setup selection cancelled.' >&2; return 1; }
          case "$answer" in [yY]|[yY][eE][sS]) languages="${languages:+$languages,}$name" ;; esac
        done
        export NVIM_LANGUAGES="$languages"
        local features=''
        for name in dap ai remote images fonts kitty; do
          answer=''
          read -r -p "Enable $name? [y/N] " answer || { echo 'Setup selection cancelled.' >&2; return 1; }
          case "$answer" in [yY]|[yY][eE][sS]) features="${features:+$features,}$name" ;; esac
        done
        export NVIM_FEATURES="${features:+$features,}-formulas"
        break ;;
      *) echo 'Enter 1, 2, 3, or 4.' ;;
    esac
  done
}
