# OSX-only stuff. Abort if not OSX.
is_osx || return 1

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

# Functions used in subsequent init scripts.

# Homebrew kegs.
function brew_tap_kegs() {
  kegs=($(setdiff "${kegs[*]}" "$(brew tap)"))
  if (( ${#kegs[@]} > 0 )); then
    e_header "Tapping Homebrew kegs: ${kegs[*]}"
    for keg in "${kegs[@]}"; do
      brew tap $keg
    done
  fi
}

function brew_has_tap {
  if [[ "$(type -P brew)" ]]; then
    local tap="$1"
    [[ "$(brew tap 2>/dev/null | grep -w "$tap")" ]] || return 1
  fi
}

# Homebrew recipes.
function brew_install_recipes() {
  recipes=($(setdiff "${recipes[*]}" "$(brew list)"))
  if (( ${#recipes[@]} > 0 )); then
    e_header "Installing Homebrew recipes: ${recipes[*]}"
    for recipe in "${recipes[@]}"; do
      brew install $recipe
    done
  fi
}

function brew_has_recipe {
  if [[ "$(type -P brew)" ]]; then
    local recipe="$1"
    [[ "$(brew list 2>/dev/null | grep -w "$recipe")" ]] || return 1
  fi
}

# Homebrew casks.
function brew_install_casks() {
  casks=($(setdiff "${casks[*]}" "$(brew cask list 2>/dev/null)"))
  if (( ${#casks[@]} > 0 )); then
    e_header "Installing Homebrew casks: ${casks[*]}"
    for cask in "${casks[@]}"; do
      brew cask install $cask
    done
    brew cask cleanup
  fi
}

function brew_has_cask {
  if [[ "$(type -P brew)" ]]; then
    local cask="$1"
    [[ "$(brew cask list 2>/dev/null | grep -w "$cask")" ]] || return 1
  fi
}
