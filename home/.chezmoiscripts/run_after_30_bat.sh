#!/bin/sh

. "${TMPDIR-/tmp}"/chezmoi-utils.sh

if [ "$(type -P bat)" ]; then
    e_header "Build bat cache"
    bat cache --build
fi
