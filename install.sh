#!/bin/sh

set -e # -e: exit on error

if [ ! "$(command -v chezmoi)" ]; then
  BIN_DIR="$HOME/.local/bin"
  CHEZMOI="$BIN_DIR/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$BIN_DIR"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$BIN_DIR"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  CHEZMOI=chezmoi
fi

# exec: replace current process with chezmoi init
exec "$CHEZMOI" init --apply dojoteef
