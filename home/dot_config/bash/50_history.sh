# shellcheck shell=bash

# History settings

# Allow use to re-edit a failed history substitution.
shopt -s histreedit
# History expansions will be verified before execution.
shopt -s histverify

# Entries beginning with space aren't added into history, and duplicate
# entries will be erased (leaving the most recent entry).
export HISTCONTROL="ignorespace:erasedups"
# Give history timestamps.
export HISTTIMEFORMAT="[%F %T] "
# Lots o' history.
export HISTSIZE=10000
export HISTFILESIZE=10000
