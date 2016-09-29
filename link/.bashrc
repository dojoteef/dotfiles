# Where the magic happens.
export DOTFILES=~/.dotfiles

# Add binaries into the path
DOTGLOB="*$DOTFILES/bin*"
if [[ -d $DOTFILES/bin ]] && [[ ! "$PATH" == "$DOTGLOB" ]]; then
  export PATH=$DOTFILES/bin:$PATH
fi

# Source all files in "source"
function src() {
  local file
  for file in $DOTFILES/source/*; do
    source "$file"
  done

  # Local .bashrc to specify machine specific settings and overrides
  if [[ -f "$HOME/.bashrc.local" ]]; then
    source "$HOME/.bashrc.local"
  fi
}

# Run dotfiles script, then source.
function dotfiles() {
  $DOTFILES/bin/dotfiles "$@" && src
}

src
