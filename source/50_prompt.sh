# If we have a custom prompt source it

promptfile="$DOTFILES/prompts/bash" 
[[ -e "$promptfile" ]] && source "$promptfile"
