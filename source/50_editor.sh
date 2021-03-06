#!/bin/bash -n

# Editing

# If neovim is installed default to use it
if [[ "$(type -P nvim)" ]]; then
  # See if there is a terminal override needed
  # for nvim to work properly
  terminfo_dir=$DOTFILES/caches/terminfo
  if [[ -d "$terminfo_dir" ]]; then
    # shellcheck disable=2139
    alias nvim="TERMINFO=$terminfo_dir/ $(type -P nvim | head -1)"
  fi

  alias vi='nvim'
  alias vim='nvim'
fi

if [[ "$(type -P nvr)" ]] && [[ "$(type -P latexmk)" ]]; then
  alias vimtex='nvr'
fi

# If kakoune is installed use it by default
if [[ "$(type -P kak)" ]]; then
    export EDITOR='kak'
    alias kak-ide='kak -e ide'
else
    export EDITOR='vim'
fi
export VISUAL="$EDITOR"
