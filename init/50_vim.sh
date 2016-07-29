# Backups, swaps and undos are stored here.
mkdir -p $DOTFILES/caches/vim

# Install vim-plug
vim_plug="$HOME/.vim/autoload/plug.vim"
[[ -f "$vim_plug" ]] || curl -fLo $vim_plug --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Download Vim plugins.
export ${VIM:="vim"}
if [[ "$(type -P $VIM)" ]]; then
  e_header "Updating $VIM plugins"
  VIM_INSTALLING=1 $VIM +PlugUpgrade +PlugUpdate +PlugClean! +qall
fi
