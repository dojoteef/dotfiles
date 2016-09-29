#!/usr/bin/env bash

# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || return 1

# Update APT.
e_header "Updating APT"
sudo apt-get -qq update
sudo apt-get -qq dist-upgrade

# Install APT packages.
# Consider universal-ctags when a stable release is available https://ctags.io
packages=(
  bash-completion
  build-essential
  cmake
  clang
  clang-tidy
  exuberant-ctags
  figlet
  git
  git-extras
  golang
  golint
  htop
  jq
  libssl-dev
  nmap
  python-dev
  python-pip
  python3-dev
  python3-pip
  pylint
  pylint3
  shellcheck
  silversearcher-ag
  telnet
  tmux
  tree
  vim # Have to have the latest vim for YouCompleteMe and UltiSnips
)

installed=(
  $(dpkg --get-selections |
  grep -v deinstall |
  awk -F '[: \t]' '{print $1}' |
  grep -F -x "$(for p in "${packages[@]}"; do printf "%s %s " "-e" "$p"; done)")
)
packages=($(echo "${installed[@]}" "${packages[@]}" | tr ' ' '\n' | sort | uniq -u))

if (( ${#packages[@]} > 0 )); then
  e_header "Installing APT packages: ${packages[*]}"
  for package in "${packages[@]}"; do
    sudo apt-get -qq install "$package"
  done
fi

# Unfortunately hub is not available on APT so get it from the latest github release
if [[ ! "$(type -P hub)" ]]; then
  # Apparently the completion directory recently changed for Debian/Ubuntu so 
  # it is no longer /etc/bash_completion.d/
  bc_dir="/usr/share/bash-completion/completions"
  bc_file="etc/hub.bash_completion.sh"

  huburl="$(curl -fsSL https://api.github.com/repos/github/hub/releases | grep browser_download_url | grep 'linux-amd64' | head -n 1 | cut -d '"' -f 4)"
  hubdir="/tmp/$(echo "${huburl}" | awk 'BEGIN {FS="/"} {print $(NF)}' | sed 's/[.]\{1,\}[^.]\{1,\}$//')"

  e_header "Downloading 'hub'" &&
  rm -rf "${hubdir}" &&
  curl -fsSL "${huburl}" | tar -C /tmp -xvzf - &> /dev/null &&
  e_header "Installing 'hub'" &&
  sudo "${hubdir}/install" &&
  sudo install -d ${bc_dir} &&
  sudo install -p -m644 "${hubdir}/${bc_file}" ${bc_dir}/hub &&
  rm -rf "${hubdir}"
fi
