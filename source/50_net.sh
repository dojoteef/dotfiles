#!/bin/bash -n

# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"

# Flush Directory Service cache
is_macos && alias flushdns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"
