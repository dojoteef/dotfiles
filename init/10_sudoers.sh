#!/usr/bin/env bash

# Installing this sudoers file makes life easier.
sudoers_file="sudoers-dotfiles"
sudoers_src=$DOTFILES/conf/$(get_os)/$sudoers_file
sudoers_dir="/etc/sudoers.d"
sudoers_dest="$sudoers_dir/$sudoers_file"
if [[ ! -e "$sudoers_dest" || "$sudoers_dest" -ot "$sudoers_src" ]]; then
  cat <<EOF
The sudoers file can be updated to allow "sudo apt-get" to be executed
without asking for a password. You can verify that this worked correctly by
running "sudo -k apt-get". If it doesn't ask for a password, and the output
looks normal, it worked.

THIS SHOULD ONLY BE ATTEMPTED IF YOU ARE LOGGED IN AS ROOT IN ANOTHER SHELL.
EOF
  if [[ $DOTDEFAULTS ]]; then
    update_sudoers="N"
  else
    read -r -n 1 -p "Update sudoers file? [y/N] " update_sudoers; echo
  fi

  if [[ "$update_sudoers" =~ [Yy] ]]; then
    e_header "Updating sudoers"
    sudo mkdir -p $sudoers_dir &&
    visudo -cf "$sudoers_src" &&
    dot_substitute sudo "$sudoers_src" "$sudoers_dest" &&
    sudo chmod 0440 "$sudoers_dest" &&
    echo "File $sudoers_dest updated." ||
    echo "Error updating $sudoers_dest file."
  else
    echo "Skipping."
  fi
fi
