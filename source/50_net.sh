#!/bin/bash -n

# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"

# Flush Directory Service cache
alias flushdns="dscacheutil -flushcache"

# View HTTP traffic
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
