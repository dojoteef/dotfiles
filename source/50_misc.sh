#!/bin/bash -n

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

alias grep='grep --color=auto'
alias egrep='grep --color=auto'
alias fgrep='grep --color=auto'

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# Set the terminal's title bar.
function titlebar() {
  echo -n $'\e]0;'"$*"$'\a'
}

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(sed 's/[, ].*//' ~/.ssh/known_hosts | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi

# Alias git to hub
# https://hub.github.com
if [[ "$(type -P hub)" ]]; then
  alias git=hub
fi
