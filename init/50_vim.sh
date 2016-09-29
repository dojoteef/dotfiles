#!/usr/bin/env bash

# Backups, swaps and undos are stored here.
mkdir -p "$DOTFILES/caches/vim"

# Install vim-plug
vim_plug="$HOME/.vim/autoload/plug.vim"
[[ -f "$vim_plug" ]] || curl -fLo "$vim_plug" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Download Vim plugins.
export VIM_PROGRAM
VIM_PROGRAM=${VIM_PROGRAM:="vim"}
if [[ "$(type -P "$VIM_PROGRAM")" ]]; then
  e_header "Updating vim plugins"
  VIM_INSTALLING=1 $VIM_PROGRAM +PlugUpgrade +PlugUpdate +PlugClean! +qall
fi
