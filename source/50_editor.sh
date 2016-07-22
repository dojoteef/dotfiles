# Editing

# If neovim is installed default to use it
if [[ "$(type -P nvim)" ]]; then
  # See if there is a terminal override needed
  # for nvim to work properly
  terminfo_dir=$DOTFILES/caches/terminfo
  if [[ -d "$terminfo_dir" ]] && [[ -e "$terminfo_dir/$TERM" ]]; then
    alias nvim="TERMINFO=$terminfo_dir nvim"
  fi

  alias vim='nvim'
fi

export EDITOR='vim'
export VISUAL="$EDITOR"
