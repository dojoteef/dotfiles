#!/usr/bin/env bash

# OSX-only stuff. Abort if not OSX.
is_osx || exit 1

if [[ "$(type -p go)" ]] && [[ ! "$(type -p golint)" ]]; then
  GOVERSION=$(go version | go version | grep -oe '\d\.\S\+')
  GOMAJOR=$(echo "$GOVERSION" | cut -f1 -d'.')
  GOMINOR=$(echo "$GOVERSION" | cut -f2 -d'.')
  if [[ $GOMAJOR -ge 1 ]] && [[ $GOMINOR -ge 5 ]]; then
    e_header "Installing golint"

    export GOPATH
    GOPATH="$TMPDIR/$(uuidgen)"
    mkdir -p "$GOPATH"

    go get -u github.com/golang/lint/golint

    install -d /usr/local/bin
    install -C "$GOPATH/bin/golint" /usr/local/bin/golint
    install -d /usr/local/share/doc/go
    install -C "$GOPATH/src/github.com/golang/lint/README.md" \
      "$GOPATH/src/github.com/golang/lint/CONTRIBUTING.md" \
      "$GOPATH/src/github.com/golang/lint/LICENSE" \
      /usr/local/share/doc/go

    rm -rf "$GOPATH"
  fi
fi

if [[ "$(type -p pip2)" ]]; then
  e_header "Installing pylint"
  pip2 -q install --upgrade pylint
fi

if [[ "$(type -p pip3)" ]]; then
  e_header "Installing pylint3"
  pip3 -q install --upgrade pylint
fi
