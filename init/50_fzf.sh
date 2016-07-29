fzf_dir="$HOME/.fzf"

# Install fzf if needed
if [[ ! -d "$fzf_dir" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $fzf_dir
else
  cd $fzf_dir && git pull
fi

# Don't update rc files, source/50_file.sh does that
$fzf_dir/install --all --no-update-rc
