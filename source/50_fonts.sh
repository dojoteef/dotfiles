#!/bin/bash -n

export NERD_FONT
if is_macos; then
  # MacOS
  NERD_FONT="$(macos_list_nerd_fonts | head -n 1)"
elif is_ubuntu; then
  # TODO: Linux
  NERD_FONT="$(fc-list :outline -f "%{family}\n" | grep -i nerd | head -n 1
  )"
fi

if [ "$NERD_FONT" ]; then
  export POWERLINE_FONT="$NERD_FONT"
fi
