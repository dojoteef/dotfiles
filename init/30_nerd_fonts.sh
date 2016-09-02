# Install all fonts
cache_dir=$DOTFILES/caches/fonts

# Create directory if it doesn't exist.
[[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"

if is_osx; then
  font_dir="$HOME/Library/Fonts"
elif is_ubuntu; then
  font_dir=".local/share/fonts"
fi
mkdir -p "$font_dir"

function getnerdfont() {
  baseurl="https://github.com/ryanoasis/nerd-fonts/raw"
  version=0.8.0
  family="$1"
  fontfile="$(echo "$2.ttf" | sed "s/ /%20/g")"
  outfile="$cache_dir/$2-$version.ttf"
  curl -fsSL "$baseurl/$version/patched-fonts/$family/complete/$fontfile" > "$outfile"

  # Copy font to the user's font directory
  cp "$outfile" "$font_dir"

  # Reset font cache on Linux
  if [[ -n $(which fc-cache) ]]; then
    fc-cache -f "$font_dir"
  fi
  echo "$2 installed"
}

e_header "Installing Nerd Fonts"
getnerdfont "Hack/Regular" "Knack Regular Nerd Font Complete Mono"
