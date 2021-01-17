#!/bin/bash -n

# macOS-only stuff. Abort if not macOS.
is_macos || return 1

# TODO: Revist this file!

# Automatically pull the Github access token from the Keychain on macOS
export GITHUB_ACCESS_TOKEN
GITHUB_ACCESS_TOKEN=$(security find-generic-password -s github_access_token -a dojoteef -w)

# Of course when brew installs bash completion it requires
# you to manually put this in your rc
if [[ "$(type -P brew)" ]]; then
  export HOMEBREW_GITHUB_API_TOKEN=$GITHUB_ACCESS_TOKEN
  if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    source "$(brew --prefix)/etc/bash_completion"
  fi
fi

# Allow usr local to over default system binaries
PATH="/usr/local/bin:$(path_remove /usr/local/bin)"
export PATH

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# MacOS does not have sudoedit by default! Fix this with an alias
alias sudoedit="sudo -e"

# Export Localization.prefPane text substitution rules.
txt_sub_backup() {
  local prefs=~/Library/Preferences/.GlobalPreferences.plist
  local backup=$DOTFILES/conf/macos/NSUserReplacementItems.plist
  /usr/libexec/PlistBuddy -x -c "Print NSUserReplacementItems" "$prefs" > "$backup" &&
  echo "File ~${backup#$HOME} written."
}

# Import Localization.prefPane text substitution rules.
txt_sub_restore() {
  local prefs=~/Library/Preferences/.GlobalPreferences.plist
  local backup=$DOTFILES/conf/macos/NSUserReplacementItems.plist
  if [[ ! -e "$backup" ]]; then
    echo "Error: file ~${backup#$HOME} does not exist!"
    return 1
  fi
  cmds=(
    "Delete NSUserReplacementItems"
    "Add NSUserReplacementItems array"
    "Merge '$backup' NSUserReplacementItems"
  )
  for cmd in "${cmds[@]}"; do /usr/libexec/PlistBuddy -c "$cmd" "$prefs"; done
}
