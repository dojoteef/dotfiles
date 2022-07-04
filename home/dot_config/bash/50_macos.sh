{{- if eq .chezmoi.os "darwin" }}
# shellcheck shell=bash

# Automatically pull the Github access token from the Keychain on macOS
export GITHUB_ACCESS_TOKEN
GITHUB_ACCESS_TOKEN=$(security find-generic-password -s github_access_token -a dojoteef -w)

# MacOS does not have sudoedit by default! Fix this with an alias
alias sudoedit="sudo -e"
{{- end }}
