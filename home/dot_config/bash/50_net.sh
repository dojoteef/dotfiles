# shellcheck shell=bash

# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"

{{- if eq .chezmoi.os "darwin" }}
# Flush Directory Service cache
alias flushdns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"
{{- end }}
