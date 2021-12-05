#!/usr/bin/env bash

# Make sure the kakoune config directory exists
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}/kak"

# Hardcoded version of kak-lsp for now...
if is_linux; then
  URL="https://github.com/kak-lsp/kak-lsp/releases/download/v11.0.1/kak-lsp-v11.0.1-x86_64-unknown-linux-musl.tar.gz"

  # Ensure .local/bin directories exist and install kak-lsp
  mkdir -p "$HOME/.local/bin"
  cd "$HOME/.local/bin" && curl -fsSL "$URL" -o - | tar xzvf /dev/stdin kak-lsp

  KAK_LSP_CONFIG_DIR="${XDG_CONFIG_HOME:=$HOME/.config}/kak-lsp"
elif is_macos; then
  KAK_LSP_CONFIG_DIR="$HOME/Library/Preferences/kak-lsp"
  [[ -e $HOME/Library/Preferences/kak-lsp/kak-lsp.toml ]] || ln -s "$DOTFILES/conf/kak-lsp.toml" "$XDG_CONFIG_HOME/kak-lsp/kak-lsp.toml"
fi

# Make sure the kak-lsp config directory exists
mkdir -p "$KAK_LSP_CONFIG_DIR"

# TODO: Override kak-lsp.toml if it exists? By default it'll exist if installed via brew, but it might be wrong...
[[ -e $KAK_LSP_CONFIG_DIR/kak-lsp.toml ]] || ln -s "$DOTFILES/conf/kak-lsp.toml" "$KAK_LSP_CONFIG_DIR/kak-lsp.toml"
[[ -e $XDG_CONFIG_HOME/kak/kakrc ]] || ln -s "$DOTFILES/conf/kakrc" "$XDG_CONFIG_HOME/kak/kakrc"
