#!/usr/bin/env bash

tmux_plugins=$HOME/.tmux/plugins/tpm
if [[ ! -d "$tmux_plugins" ]]; then
  e_header "Installing tpm (tmux plugin manager)"
  git clone https://github.com/tmux-plugins/tpm --depth 1 "$tmux_plugins"
  "$tmux_plugins/bin/install_plugins"
else
  e_header "Updating tpm (tmux plugin manager)"
  cd "$tmux_plugins" || \
    (e_error "Unable to cd into $tmux_plugins. Possibly check permissions." && exit 1)
  git fetch origin master --depth 1 && git checkout -B master origin/master
  "$tmux_plugins/bin/clean_plugins" # remove plugins no longer in the list
  "$tmux_plugins/bin/install_plugins" # install new plugins
  "$tmux_plugins/bin/update_plugins" all # update existing plugins
fi

# Use the tmux-256color terminfo as defined by kakoune
curl -fsSL https://raw.githubusercontent.com/mawww/kakoune/f140b01b/contrib/tmux-256color.terminfo | tic /dev/stdin
