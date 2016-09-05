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
  exuberant-ctags
  fbterm
  figlet
  git
  git-extras
  golang
  htop
  jq
  libssl-dev
  nmap
  python-dev
  python-pip
  python3-dev
  python3-pip
  silversearcher-ag
  telnet
  tmux
  tree
  vim # Have to have the latest vim for YouCompleteMe and UltiSnips
)

packages=($(setdiff "${packages[*]}" "$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')"))

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
  hubdir="/tmp/$(echo ${huburl} | awk 'BEGIN {FS="/"} {print $(NF)}' | sed 's/[.]\{1,\}[^.]\{1,\}$//')"

  e_header "Downloading 'hub'" &&
  rm -rf ${hubdir} &&
  curl -fsSL ${huburl} | tar -C /tmp -xvzf - &> /dev/null &&
  e_header "Installing 'hub'" &&
  sudo ${hubdir}/install &&
  sudo install -d ${bc_dir} &&
  sudo install -p -m644 ${hubdir}/${bc_file} ${bc_dir}/hub &&
  rm -rf ${hubdir}
fi

# Need to setup fbterm correctly for non-root users
if [[ "$(type fbterm)" ]]; then
  function setfbtermcap () {
    local cap="cap_$1+$2"
    setcap -v "$cap" $(command -v fbterm)
    if [[ $? -ne  0 ]]; then
      sudo setcap "$cap" $(command -v fbterm)
    fi
  }

  # Have to add to group 'video' so they can access framebuffer
  sudo gpasswd --add $USER video

  # Have to add these capabilities for keyboard to work correctly
  setfbtermcap 'sys_admin' 'ep'
  setfbtermcap 'sys_tty_config' 'ep'
fi
