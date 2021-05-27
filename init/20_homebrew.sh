#!/usr/bin/env bash

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && exit 1

e_header "Updating Homebrew"
brew doctor
brew update
brew upgrade

if ! brew bundle "--file=$DOTFILES/conf/brew/core" check &> /dev/null; then
  e_header "Installing core requirements"
  brew bundle "--file=$DOTFILES/conf/brew/core"
fi

if ! brew bundle "--file=$DOTFILES/conf/brew/devel" check &> /dev/null; then
  if [[ $DOTDEFAULTS ]]; then
    install_devel="Y"
  else
    read -r -n 1 -p "Install development tools? [Y/n] " install_devel; echo
  fi

  if [[ ! "$install_devel" =~ [Nn] ]]; then
    e_header "Installing development tools"
    brew bundle "--file=$DOTFILES/conf/brew/devel"
  fi
fi


if is_macos && ! brew bundle "--file=$DOTFILES/conf/macos/brew/casks" check &> /dev/null; then
  if [[ $DOTDEFAULTS ]]; then
    install_casks="Y"
  else
    read -r -n 1 -p "Install casks? [Y/n] " install_casks; echo
  fi

  if [[ ! "$install_casks" =~ [Nn] ]]; then
    e_header "Installing casks"
    brew bundle "--file=$DOTFILES/conf/macos/brew/casks"
  fi
fi


if ! brew bundle "--file=$DOTFILES/conf/macos/brew/completions" check &> /dev/null; then
  if [[ $DOTDEFAULTS ]]; then
    install_completions="Y"
  else
    read -r -n 1 -p "Install completions? [Y/n] " install_completions; echo
  fi

  if [[ ! "$install_completions" =~ [Nn] ]]; then
    e_header "Installing completions"
    brew bundle "--file=$DOTFILES/conf/brew/completions"
  fi
fi

# Misc cleanup!
brew cleanup

# This is where brew stores its binary symlinks
binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

if sudo_allowed; then
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
fi
