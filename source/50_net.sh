#!/bin/bash -n

# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"

# Flush Directory Service cache
is_osx && alias flushdns="dscacheutil -flushcache"
