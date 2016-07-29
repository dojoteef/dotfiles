# If we have a custom prompt source it

promptfile="$DOTFILES/caches/prompts/bash" 
[[ -f "$promptfile" ]] && source "$promptfile"
