# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Homebrew completions
kegs=(homebrew/completions)
brew_tap_kegs
recipes=(
  launctl-completion
  pip-completion
)
