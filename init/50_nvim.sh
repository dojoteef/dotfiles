#!/usr/bin/env bash

# Need to touch .vimrc in case it does not exist otherwise 'ln' will fail
touch "$HOME/.vimrc"

# Additionally ensure the .vim directory exists, though it is non fatal if it is missing
mkdir -p "$HOME/.vim"

# Taken from the nvim-from-vim docs:
# https://neovim.io/doc/user/nvim.html#nvim-from-vim
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"
[[ -e $XDG_CONFIG_HOME/nvim ]] || ln -s "$HOME/.vim" "$XDG_CONFIG_HOME/nvim"
[[ -e $XDG_CONFIG_HOME/nvim/init.vim ]] || ln -s "$HOME/.vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"

if sudo_allowed; then
  if [[ "$(type -P nvim)" ]]; then
    e_header "Updating neovim"
  else
    e_header "Installing neovim"
  fi

  # Exit if Homebrew is not installed.
  [[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

  if ! brew bundle "--file=$DOTFILES/conf/brew/neovim" check &> /dev/null; then
    brew bundle "--file=$DOTFILES/conf/brew/neovim"
  fi
fi

if [[ "$(type -P nvim)" ]]; then
  e_header "Ensuring latest neovim packages for python3 are installed"
  # pip3 -q install --upgrade pynvim
  # See https://github.com/mhinz/neovim-remote/issues/134#issuecomment-586787280
  python3 -m pip -q install pynvim==0.3.2
  python3 -m pip -q install --upgrade neovim-remote
fi

###########################################################################
# Now to address the elephant in the room... fixing the discrepancy between
# terminfo and termios for neovim as it does not handle it in the more
# traditional way of ignoring terminfo Backspace and using termios VERASE
# instead. See more discussion on the topic at this link:
# https://github.com/neovim/neovim/issues/2048
#
# And these specific comments that better detail the issue:
# https://github.com/neovim/neovim/issues/2048#issuecomment-78045837
# https://github.com/neovim/neovim/issues/2048#issuecomment-217755170
###########################################################################
fix_terminfo() {
  local term override_dir terminfo_dir termios_erase terminfo_erase
  term=$1
  terminfo_dir=$DOTFILES/caches/terminfo

  if [[ -d "$terminfo_dir" ]]; then
    override_dir="$terminfo_dir"
  fi

  # First see what termios thinks erase is
  if is_macos; then
    termios_erase="$(stty -g | grep -w 'erase' | sed 's/.*[^a-z]erase=\([^:]\{1,\}\).*/0x\1/' | xargs printf %o)"
  else
    termios_erase="$(stty -g | awk -F ':' '{print "0x"$7}' | xargs printf %o)"
  fi

  # Then see what terminfo thinks backspace is
  terminfo_erase="$(TERMINFO="$override_dir" tput "-T$term" kbs)"
  if [[ "$(printf "%s" "$terminfo_erase" | od -t oC | tail -1)" -eq 1 ]]; then
    # If it is a single character then converting it with od is the correct approach,
    # otherwise it means it's a character sequence which is more likely a octal or hex number.
    terminfo_erase="$(printf "%s" "$terminfo_erase" | od -t oC | head -n 1 | awk '{print $2}')"
  fi

  # If they don't agree then make terminfo use the termios value
  if [[ "$termios_erase" ]] && [[ "$terminfo_erase" ]] && [[ "$termios_erase" != "$terminfo_erase" ]]; then
    echo "Fixing neovim terminfo for $term"
    echo "termios_erase: $termios_erase, terminfo_erase=$terminfo_erase"
    local terminfo_file re_identifier re_equals re_value cmd
    terminfo_file=/tmp/$term.ti

    re_identifier="[[:space:],]\{1,\}kbs"
    re_equals="[[:space:]]*=[[:space:]]*"
    re_value="[^,]\{1,\}"

    cmd="infocmp $term | sed 's/\($re_identifier$re_equals\)\($re_value\)/\1$termios_erase'/ > $terminfo_file"
    bash -c "$cmd"

    mkdir -p "$terminfo_dir"
    tic -o "$terminfo_dir" "$terminfo_file"
    rm -f "$terminfo_file"
  fi
}

# Fix commonly used terminal types
if [[ "$(type -P nvim)" ]]; then
  e_header "Fixing terminfo for neovim"
  fix_terminfo "screen-256color"
  fix_terminfo "xterm-256color"
fi
