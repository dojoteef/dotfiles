if is_osx; then
  # MacOS
  export NERD_FONT="$(osx_list_nerd_fonts | head -n 1)"
  export POWERLINE_FONT="$NERD_FONT"
elif is_ubuntu; then
  # TODO: Linux
  export NERD_FONT=
  export POWERLINE_FONT=
fi
