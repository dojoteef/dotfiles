#!/usr/bin/env bash

# Ensure the .local/bin and .config/kak-lsp directories exist
mkdir -p "$HOME/.local/bin"
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}/kak"
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}/kak-lsp"

# Hardcoded version of kak-lsp for now...
if is_macos; then
  TARBALL="kak-lsp-v8.0.0-x86_64-apple-darwin.tar.gz"
elif is_linux; then
  TARBALL="kak-lsp-v8.0.0-x86_64-unknown-linux-musl.tar.gz"
fi
URL="https://github.com/kak-lsp/kak-lsp/releases/download/v8.0.0/$TARBALL"

cd "$HOME/.local/bin" && curl -fsSL "$URL" -o - | tar xzvf /dev/stdin kak-lsp
[[ -e $XDG_CONFIG_HOME/kak/kakrc ]] || ln -s "$DOTFILES/conf/kakrc" "$XDG_CONFIG_HOME/kak/kakrc"
[[ -e $XDG_CONFIG_HOME/kak-lsp/kak-lsp.toml ]] || ln -s "$DOTFILES/conf/kak-lsp.toml" "$XDG_CONFIG_HOME/kak-lsp/kak-lsp.toml"
