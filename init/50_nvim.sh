# Need to touch .vimrc in case it does not exist otherwise 'ln' will fail
touch $HOME/.vimrc

# Additionally ensure the .vim directory exists, though it is non fatal if it is missing
mkdir -p $HOME/.vim

# Taken from the nvim-from-vim docs:
# https://neovim.io/doc/user/nvim.html#nvim-from-vim
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s $HOME/.vim $XDG_CONFIG_HOME/nvim
ln -s $HOME/.vimrc $XDG_CONFIG_HOME/nvim/init.vim

[[ "$(type -P nvim)" ]] && e_header "Updating neovim" || e_header "Installing neovim"
if is_osx then;
  # Exit if Homebrew is not installed.
  [[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

  # Ensure the neovim keg has been tapped
  kegs=(neovim/neovim)
  brew_tap_kegs

  # Now install neovim
  recipes=(neovim)
  brew_install_recipes
else
  # Add the Personal Package Archive for neovim
  sudo apt-get -qq install software-properties-common
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt-get -qq update

  # Install it!
  sudo apt-get -qq install neovim
fi

e_header "Ensuring latest neovim package for python2/3 is installed"
sudo pip2 install --upgrade neovim
sudo pip3 install --upgrade neovim

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

# First see what termios thinks VERASE is
re_identifier='[[:space:];]\{1,\}erase'
re_equals='[[:space:]]*=[[:space:]]*'
re_value='[^;]\{1,\}'
cmd="stty -a | grep '$re_identifier' | sed 's/.*$re_identifier$re_equals\($re_value\).*/\1/'"
termios_erase=$(eval $cmd)

# Then see what terminfo thinks Backspace is
re_identifier='[[:space:];]\{1,\}kbs'
re_value='[^,]\{1,\}'
cmd="infocmp $TERM | grep '$re_identifier' | sed 's/.*$re_identifier$re_equals\($re_value\).*/\1/'"
terminfo_erase=$(eval $cmd)

# If they don't agree then make terminfo use the termios value
if [ "$termios_erase" != "$terminfo_erase" ]; then
  e_header "Fixing nvim terminfo"
  terminfo_file=/tmp/$TERM.ti
  terminfo_dir=$DOTFILES/caches/terminfo

  cmd="infocmp $TERM | \
       sed 's/\($re_identifier$re_equals\)\($re_value\)/\1$termios_erase'/ \
       > $terminfo_file"

  mkdir -p $terminfo_dir
  tic -o $terminfo_dir $terminfo_file
  rm -f $terminfo_file
fi

# Need this such that later uses of vim command (see 50_vim.sh and
# 60_prompts.sh) use the correct vim.
alias vim='nvim'
