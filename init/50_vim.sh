#!/usr/bin/env bash

# Backups, swaps and undos are stored here.
mkdir -p "$DOTFILES/caches/vim"

# Install vim-plug
vim_plug="$HOME/.vim/autoload/plug.vim"
[[ -f "$vim_plug" ]] || curl -fLo "$vim_plug" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Download Vim plugins.
if [[ "$(type -P vim)" ]]; then
  e_header "Updating vim plugins"
  VIM_INSTALLING=1 vim +PlugUpgrade +PlugUpdate +PlugClean! +qall
fi
