#!/usr/bin/env bash

# OSX-only stuff. Abort if not OSX.
is_osx || exit 1

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

e_header "Updating Homebrew"
brew doctor
brew update
brew upgrade

brew bundle "--file=$DOTFILES/conf/osx/brew/core" check &> /dev/null
if [[ $? -ne 0 ]]; then
  e_header "Installing core requirements"
  brew bundle "--file=$DOTFILES/conf/osx/brew/core"
fi

brew bundle "--file=$DOTFILES/conf/osx/brew/devel" check &> /dev/null
if [[ $? -ne 0 ]]; then
  if [[ $DOTDEFAULTS ]]; then
    install_devel="Y" 
  else
    read -r -n 1 -p "Install development tools? [Y/n] " install_devel; echo
  fi

  if [[ ! "$install_devel" =~ [Nn] ]]; then
    brew bundle "--file=$DOTFILES/conf/osx/brew/devel"
  fi
fi

brew bundle "--file=$DOTFILES/conf/osx/brew/casks" check &> /dev/null
if [[ $? -ne 0 ]]; then
  if [[ $DOTDEFAULTS ]]; then
    install_casks="Y" 
  else
    read -r -n 1 -p "Install casks? [Y/n] " install_casks; echo
  fi

  if [[ ! "$install_casks" =~ [Nn] ]]; then
    brew bundle "--file=$DOTFILES/conf/osx/brew/casks"
  fi
fi

brew bundle "--file=$DOTFILES/conf/osx/brew/completions" check &> /dev/null
if [[ $? -ne 0 ]]; then
  if [[ $DOTDEFAULTS ]]; then
    install_completions="Y" 
  else
    read -r -n 1 -p "Install completions? [Y/n] " install_completions; echo
  fi

  if [[ ! "$install_completions" =~ [Nn] ]]; then
    brew bundle "--file=$DOTFILES/conf/osx/brew/completions"
  fi
fi

# Misc cleanup!

# This is where brew stores its binary symlinks
binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

# htop
if [[ "$(type -P "$binroot/htop")" ]] && [[ "$(stat -L -f "%Su:%Sg" "$binroot/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "$binroot/htop") & 4))" ]]; then
  e_header "Updating htop permissions"
  sudo chown root:wheel "$binroot/htop"
  sudo chmod u+s "$binroot/htop"
fi

# bash
if [[ "$(type -P "$binroot/bash")" ]] && ! grep -qw "$binroot/bash" /etc/shells; then
  e_header "Adding $binroot/bash to the list of acceptable shells"
  echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
fi

if [[ "$(dscl . -read ~ UserShell | awk '{print $2}')" != "$binroot/bash" ]]; then
  e_header "Making $binroot/bash your default shell"
  sudo chsh -s "$binroot/bash" "$USER" >/dev/null 2>&1
  e_arrow "Please exit and restart all your shells."
fi
