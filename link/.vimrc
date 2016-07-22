" Change mapleader
let mapleader=","

" Move more naturally up/down when wrapping is enabled.
nnoremap j gj
nnoremap k gk

" Local dirs
set backupdir=$DOTFILES/caches/vim
set directory=$DOTFILES/caches/vim
set undodir=$DOTFILES/caches/vim

" Create vimrc autocmd group and remove any existing vimrc autocmds,
" in case .vimrc is re-sourced.
augroup vimrc
  autocmd!
augroup END

" Visual settings
set cursorline " Highlight current line
set number " Enable line numbers.
set showtabline=1 " Always show tab bar.
set relativenumber " Use relative line numbers. Current line is still in status bar.
set title " Show the filename in the window titlebar.
set nowrap " Do not wrap lines.
set noshowmode " Don't show the current mode (airline.vim takes care of us)
set laststatus=2 " Always show status line

" Show absolute numbers in insert mode, otherwise relative line numbers.
autocmd vimrc InsertEnter * :set norelativenumber
autocmd vimrc InsertLeave * :set relativenumber

" Make it obvious where text would wrap with 'textwidth'
let &colorcolumn=+1

" Scrolling
set scrolloff=0 " Override default in sensible.vim, do not include context above/below cursor when scrolling

" Indentation
" TODO: Make these into autocmd per filetype
set shiftwidth=2 " The # of spaces for indenting.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=2 " Tabs indent only 2 spaces
set expandtab " Expand tabs to spaces

" Reformatting
set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command.

" Search / replace
set hlsearch " Highlight searches
map <silent> <leader>/ <Esc>:nohlsearch<CR> " Clear last search

if executable('ag') " The Silver Searcher
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " bind K to grep word under cursor
  nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

  " New command :Ag which takes standard ag arguments
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
endif

" Ignore things
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*

" Vim commands
set hidden " When a buffer is brought to foreground, remember undo history and marks.
set report=0 " Show all changes.
set mouse=a " Enable mouse in all modes.
if has('mouse_sgr')
  set ttymouse=sgr
endif

" Splits
set splitbelow " New split goes below
set splitright " New split goes right

" Ctrl-J/K/L/H select split
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" FILE TYPES

autocmd vimrc BufRead .vimrc,*.vim set keywordprg=:help
autocmd vimrc BufRead,BufNewFile *.md set filetype=markdown
autocmd vimrc BufRead,BufNewFile *.tmpl set filetype=html

" PLUGINS

" Airline
let g:airline_powerline_fonts = 1
let g:airline_exclude_preview = 1 " See https://github.com/vim-airline/vim-airline/issues/1125
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s '
let g:airline#extensions#tabline#buffer_nr_show = 1
"let g:airline#extensions#tabline#fnamecollapse = 0
"let g:airline#extensions#tabline#fnamemod = ':t'

" Promptline
let g:promptline_theme = 'airline'
let g:promptline_preset = {
  \'a': [ promptline#slices#host(), promptline#slices#user() ],
  \'b': [ promptline#slices#cwd() ],
  \'c' : [ promptline#slices#vcs_branch(), promptline#slices#git_status() ],
  \'warn' : [ promptline#slices#last_exit_code() ]
  \ }

" NERDTree
let NERDTreeShowHidden = 1
let NERDTreeMouseMode = 2
let NERDTreeMinimalUI = 1
map <leader>n :NERDTreeToggle<CR>
autocmd vimrc StdinReadPre * let s:std_in=1
" If no file or directory arguments are specified, open NERDtree.
" If a directory is specified as the only argument, open it in NERDTree.
autocmd vimrc VimEnter *
  \ if argc() == 0 && !exists("s:std_in") |
  \   NERDTree |
  \ elseif argc() == 1 && isdirectory(argv(0)) |
  \   bd |
  \   exec 'cd' fnameescape(argv(0)) |
  \   NERDTree |
  \ end
let g:NERDTreeIndicatorMapCustom = {
  \ "Modified"  : "✹",
  \ "Staged"    : "✚",
  \ "Untracked" : "✭",
  \ "Renamed"   : "➜",
  \ "Unmerged"  : "═",
  \ "Deleted"   : "✖",
  \ "Dirty"     : "✗",
  \ "Clean"     : "✔︎",
  \ "Unknown"   : "?"
  \ }

" Signify
let g:signify_vcs_list = ['git']

" YouCompleteMe
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']

" UltiSnips
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
autocmd FileType c UltiSnipsAddFiletypes c
autocmd FileType cpp UltiSnipsAddFiletypes cpp
autocmd FileType css UltiSnipsAddFiletypes css
autocmd FileType go UltiSnipsAddFiletypes go
autocmd FileType json UltiSnipsAddFiletypes json
autocmd FileType lua UltiSnipsAddFiletypes lua
autocmd FileType html UltiSnipsAddFiletypes html
autocmd FileType python UltiSnipsAddFiletypes python
autocmd FileType xml UltiSnipsAddFiletypes xml

" vim-multiple-cursors
" Fix YouCompleteMe with vim-multiple-cursors
" (https://github.com/terryma/vim-multiple-cursors/issues/122#issuecomment-114654967)

" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
  if exists('*youcompleteme#EnableCursorMovedAutocommands')
    call youcompleteme#DisableCursorMovedAutocommands()
  endif
endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
function! Multiple_cursors_after()
  if exists('*youcompleteme#EnableCursorMovedAutocommands')
    call youcompleteme#EnableCursorMovedAutocommands()
  endif
endfunction

" Syntastic
" Lua checkers
"let g:syntastic_check_on_open = 1
"let g:syntastic_lua_checkers = ["luac", "luacheck"]
"let g:syntastic_lua_luacheck_args = "--no-unused-args" 

" vim-commentary
" autocmd FileType apache setlocal commentstring=#\ %s " example support for apache comments

" https://github.com/junegunn/vim-plug
" Reload .vimrc and :PlugInstall to install plugins.
let s:nvim = has('nvim') && exists('*jobwait')
if !s:nvim
  " This is needed in order to install YouCompleteMe if
  " not using neovim see:
  " https://github.com/Valloric/YouCompleteMe/issues/1751#issuecomment-151893905
  let g:plug_timeout = 9999
endif

call plug#begin('~/.vim/plugged')
" Themes
Plug 'vim-airline/vim-airline'
Plug 'edkolev/promptline.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'jnurmine/Zenburn'

" Syntax
Plug 'mhinz/vim-signify'
Plug 'scrooloose/syntastic'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" File Explorer
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" tmux
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'

" Misc
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
call plug#end()

" Theme / Syntax highlighting
set background=dark
colorscheme zenburn
