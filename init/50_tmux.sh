tmux_plugins=$HOME/.tmux/plugins/tpm
if [[ ! -d "$tmux_plugins" ]]; then
  e_header "Installing tpm (tmux plugin manager)"
  git clone https://github.com/tmux-plugins/tpm --depth 1 $tmux_plugins
  $tmux_plugins/bin/install_plugins
else
  e_header "Updating tpm (tmux plugin manager)"
  cd $tmux_plugins
  prev_head="$(git rev-parse HEAD)"
  git pull --depth 1
  if [[ "$(git rev-parse HEAD)" != "$prev_head" ]]; then
    e_header "Changes detected, updating plugins"
    $tmux_plugins/bin/clean_plugins # remove plugins no longer in the list
    $tmux_plugins/bin/update_plugins all # update all plugins
  fi
fi
