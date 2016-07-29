# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew casks need Homebrew to install." && return 1

# Hack to show the first-run brew-cask password prompt immediately.
brew cask info this-is-somewhat-annoying 2>/dev/null

# Fonts are in a separate keg
kegs=(caskroom/fonts)
brew_tap_kegs

# Homebrew casks
e_header "Installing fonts"
casks=(
  font-inconsolata-for-powerline
)

brew_install_casks
