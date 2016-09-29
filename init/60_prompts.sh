#!/usr/bin/env bash

prompt_dir=$DOTFILES/caches/prompts

# Create directory if it doesn't exist
[[ -d "$prompt_dir" ]] || mkdir -p "$prompt_dir"

# Create bash and tmux prompts using vim-airline themes
# by using promptline and tmuxline respectively
if [[ "$(type -P "$VIM")" ]]; then
  echo "Updating bash prompt"
  # Must delete the previous prompt file because Tmuxline will
  # not overwrite the existing one. It shouldn't be modified
  # outside of this script so it's fine to overwrite it.
  rm -f "$prompt_dir/bash"

  # Now generate the new snapshot
  VIM_INSTALLING=1 \
    $VIM "+PromptlineSnapshot $prompt_dir/bash" +qall
  if [[ "$(type -P tmux)" ]]; then
    echo "Updating tmux prompt"
    # Similar to Promptline, Tmuxline will not overwrite the snapshot.
    rm -f "$prompt_dir/tmux"

    # Have to convince Tmuxline that it's in a TMUX session otherwise
    # it will not run, even though it runs fine without being in a session.
    VIM_INSTALLING=1 TMUX="Installing" \
      $VIM +Tmuxline "+TmuxlineSnapshot $prompt_dir/tmux" +qall

    # Remove 'status-utf8'. It is deprecated and generates a warning.
    # https://github.com/edkolev/tmuxline.vim/issues/53
    # https://github.com/edkolev/tmuxline.vim/issues/56
    sed -i'' -e '/status-utf8/d' "$DOTFILES/caches/prompts/tmux"
  fi

  # Now make sure to clean out tmuxline and promptline as they
  # should only exist during installation.
  $VIM +PlugClean! +qall
fi
