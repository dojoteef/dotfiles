#!/bin/sh

cat <<"EOF" > ${TMPDIR-/tmp}/chezmoi-utils.sh
e_header()   { echo "\n\033[1m$*\033[0m"; }
e_success()  { echo " \033[1;32m✔\033[0m  $*"; }
e_error()    { echo " \033[1;31m✖\033[0m  $*"; }
e_arrow()    { echo " \033[1;34m➜\033[0m  $*"; }

export -f e_header
export -f e_success
export -f e_error
export -f e_arrow
EOF
