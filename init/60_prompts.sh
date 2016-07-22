prompt_dir=$DOTFILES/prompts

# Create directory if it doesn't exist
[[ -d "$prompt_dir" ]] || mkdir -p "$prompt_dir"

# Create bash and tmux prompts using vim-airline themes
# by using promptline and tmuxline respectively
if [[ "$(type -P vim)" ]]; then
  vim "+PromptlineSnapshot $prompt_dir/bash" +qall
  if [[ "$(type -P tmux)" ]]; then
    vim +Tmuxline "+TmuxlineSnapshot $prompt_dir/tmux" +qall
  fi
fi
