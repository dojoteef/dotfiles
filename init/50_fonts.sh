# Install all powerline fonts

cache_dir=$DOTFILES/caches/fonts

# Create directory if it doesn't exist.
[[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"

powerline_fonts="$cachedir/powerline-fonts"
if [[ ! -d "$powerline_fonts" ]]; then
  e_header "Installing powerline fonts"
  git clone --depth 1 git://github.com/powerline/fonts.git $powerline_fonts
  cd $powerline_fonts
  ./install.sh
else
  # Make sure we have the latest files.
  e_header "Updating powerline fonts"
  cd $powerline_fonts
  prev_head="$(git rev-parse HEAD)"
  git pull --depth 1
  if [[ "$(git rev-parse HEAD)" != "$prev_head" ]]; then
    e_header "Changes detected, installing updated fonts"
    ./install.sh
  fi
fi
