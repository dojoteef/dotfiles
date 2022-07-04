# shellcheck shell=bash

# If kakoune is installed use it by default
if [[ "$(type -P kak)" ]]; then
    export EDITOR='kak'
    alias kak-ide='kak -e ide'
elif [[ "$(type -P vim)" ]]; then
    export EDITOR='vim'
fi
export VISUAL="$EDITOR"
