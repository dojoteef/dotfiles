""""""""""""""""""""""""
" GLOBAL VARIABLES {{{1
""""""""""""""""""""""""
" Must be before any multibyte characters are used
scriptencoding utf-8

" Only allow some configuration settings during install
let g:vim_installing = $VIM_INSTALLING

" For some reason doing nvim +PluginInstall errors for vim-plug and
" vim-sensible if I don't do this.
let g:syntax_on=g:vim_installing

" See if vim is running in a tmux session
let g:tmux = $TMUX

" Useful OS detection
if has('unix')
  let s:uname = system('uname -a')
  let g:osx = s:uname =~? 'darwin'
  let g:ubuntu = s:uname =~? 'ubuntu'
endif

" Where plugins get installed
let s:plugin_directory = '~/.vim/plugged'

""""""""""""""""""""""""
" INSTALL PLUGINS {{{1
""""""""""""""""""""""""
" https://github.com/junegunn/vim-plug
" Reload .vimrc and :PlugInstall to install plugins.
let s:nvim = has('nvim') && exists('*jobwait')
if !s:nvim
  " This is needed in order to install YouCompleteMe if not using neovim see:
  " https://github.com/Valloric/YouCompleteMe/issues/1751#issuecomment-151893905
  let g:plug_timeout = 9999
endif

" For some reason if this is a script var (s:var) vim complains that it does
" not exist when using it in the Plug function, so make it a buffer var
" (b:var).
let b:ycm_install_cmd = './install.py'
if executable('clang')
  let b:ycm_install_cmd .= ' --clang-completer'
endif

if executable('go')
  let b:ycm_install_cmd .= ' --gocode-completer'
endif

call plug#begin(s:plugin_directory)
" Themes
Plug 'jnurmine/Zenburn'
if g:vim_installing
  " Only enable promptline and tmuxline when installing. Generate a
  " configuration file that is then sourced from the appropriate place.
  Plug 'vim-airline/vim-airline'
        \ | Plug 'vim-airline/vim-airline-themes'
        \ | Plug 'edkolev/promptline.vim'
        \ | Plug 'edkolev/tmuxline.vim'
else
  Plug 'vim-airline/vim-airline'
        \ | Plug 'vim-airline/vim-airline-themes'
endif

" VCS
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'

" Syntax
Plug 'dojoteef/neomake' | Plug 'dojoteef/neomake-autolint'
Plug 'sheerun/vim-polyglot'
Plug 'Yggdroot/indentLine'
Plug 'ynkdir/vim-vimlparser', { 'for': 'vim' }
      \ | Plug 'syngan/vim-vimlint', { 'for': 'vim' }
Plug 'junegunn/vader.vim', { 'on': 'Vader', 'for': 'vader' }
Plug 'romainl/vim-qf'
" Plug 'w0rp/ale' " TODO: Checkout when you have time

" Tags
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags' ", { 'branch': 'buffer-tagfiles' }
  Plug 'majutsushi/tagbar'
endif

" Completions
if executable('go')
  Plug 'fatih/vim-go', { 'for': 'go' }
endif
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Valloric/YouCompleteMe', { 'do': b:ycm_install_cmd }
      \ | Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
" Plug 'maralla/completor.vim' " TODO: Checkout when you have time

" Search & Navigation
Plug 'osyo-manga/vim-over'
Plug 'haya14busa/incsearch.vim' | Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'easymotion/vim-easymotion' | Plug 'haya14busa/incsearch-easymotion.vim'

" File Explorer
if executable('fzf')
  Plug '~/.fzf' | Plug 'junegunn/fzf.vim'
endif
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
      \ | Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }

" tmux
Plug 'tmux-plugins/vim-tmux'

" Misc
Plug 'mbbill/undotree'
Plug 'junegunn/vim-peekaboo'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'

" Dev icons (must be last)
" https://github.com/ryanoasis/vim-devicons#step-3-configure-vim
if !empty($NERD_FONT)
  Plug 'ryanoasis/vim-devicons'
endif
call plug#end()

""""""""""""""""""""""""
" GENERAL {{{1
""""""""""""""""""""""""
" Local dirs
set backupdir=$DOTFILES/caches/vim
set directory=$DOTFILES/caches/vim

if has('persistent_undo')
  set undodir=$DOTFILES/caches/vim
  set undofile
endif

" Create vimrc autocmd group and remove any existing vimrc autocmds,
" in case .vimrc is re-sourced.
augroup vimrc
  autocmd!
augroup END

""""""""""""""""""""""""
" VISUAL SETTINGS {{{1
""""""""""""""""""""""""
set cursorline " Highlight current line
set number " Enable line numbers.
set showtabline=1 " Always show tab bar.
set relativenumber " Use relative line numbers. Current line is still in status bar.
set title " Show the filename in the window titlebar.
set nowrap " Do not wrap lines.
set noshowmode " Don't show the current mode (airline.vim takes care of us)
set laststatus=2 " Always show status line
set colorcolumn=+1 " Make it obvious where text would wrap with 'textwidth'
set background=dark
colorscheme desert
syntax enable

function! s:AddSyntaxComments(keywords)
  " Only execute if the syntax type is known
  if empty(&syntax)
    return
  endif

  execute printf('syntax keyword %sTodo containedin=%sComment %s',
        \ &syntax, &syntax, join(a:keywords))
endfunction

" Additional highlighting for comment keywords (for most filetypes only TODO,
" FIXME, and XXX exist by default)
autocmd vimrc FileType * call s:AddSyntaxComments(['BUG', 'HACK', 'NOTE', 'INFO'])

" There is a potential for screen flicker, these next two settings
" should help address any screen flicker issues whether running in tmux or
" not.

" https://sunaku.github.io/vim-256color-bce.html
if &term =~# '256color'
  set t_ut=
endif

" https://github.com/neovim/neovim/issues/4210
if g:tmux
  set noshowcmd
  highlight ALL ctermbg=NONE
endif

" Show absolute numbers in insert mode, otherwise relative line numbers.
autocmd vimrc InsertEnter * :set norelativenumber
autocmd vimrc InsertLeave * :set relativenumber

""""""""""""""""""""""""
" USER INTERFACE {{{1
""""""""""""""""""""""""
" New split goes on top mainly so preview window does not conflict with the
" completion popup.
"
" NOTE: If I can think of a better solution to have it splitbelow normally
" and preview window gets a split above I might revisit this.
set nosplitbelow
set splitright " New split goes to the right
set hidden " When a buffer is brought to foreground, remember undo history and marks.
set report=0 " Show all changes.
set mouse=a " Enable mouse in all modes.
set timeout
set timeoutlen=250
if has('mouse_sgr')
  set ttymouse=sgr
endif

" Since python uses whitespace to denote structures, foldmethod=indent works
" reasonably well, so use it rather than a plugin. Additionally set a
" textwidth of 100 (PEP8 allows for lines up to 100 characters if desired).
autocmd vimrc FileType python set foldmethod=indent textwidth=100

" Override default in sensible.vim, do not include context above/below cursor
" when scrolling. Have to implement it this way because sensible.vim will
" set scrolloff=1 if it is 0, which is the value I want and it cannot be
" overridden due to the order of sourcing sensible.vim files.
autocmd vimrc VimEnter * :set scrolloff=0

" Automatically combine location list entries into the quickfix list
autocmd vimrc BufWinEnter,BufWinLeave,BufWipeout <buffer> call s:quickfix_combine()

""""""""""""""""""""""""
" FORMATTING {{{1
""""""""""""""""""""""""
set shiftwidth=2 " The # of spaces for indenting.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=2 " Tabs indent only 2 spaces
set expandtab " Expand tabs to spaces
set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command.
set hlsearch " Highlight searches

""""""""""""""""""""""""
" KEYMAPPINGS {{{1
""""""""""""""""""""""""
" Change mapleader
let g:mapleader=','

" Move more naturally up/down when wrapping is enabled.
nnoremap j gj
nnoremap k gk

" Ctrl-J/K/L/H select split
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" Toggle paste
noremap <silent> <leader>pp :set invpaste paste?<CR>

" Allow saving of files as sudo when I forgot to start vim using sudo.
cnoremap w!! w !sudo tee > /dev/null %

""""""""""""""""""""""""
" FILE TYPES {{{1
""""""""""""""""""""""""
autocmd vimrc BufRead .vimrc,*.vim set keywordprg=:help
autocmd vimrc BufRead,BufNewFile *.md set filetype=markdown
autocmd vimrc BufRead,BufNewFile *.tmpl set filetype=html

" This is the default set of extensions that the zip plugin (which is a global
" default plugin that comes with vim) uses.
let g:zipPlugin_ext = '*.zip,*.jar,*.xpi,*.ja,*.war,*.ear,*.celzip,*.oxt,*.kmz'
let g:zipPlugin_ext += ',*.wsz,*.xap,*.docm,*.dotx,*.dotm,*.potx,*.potm,*.ppsx'
let g:zipPlugin_ext += ',*.ppsm,*.pptx,*.pptm,*.ppam,*.sldx,*.thmx,*.xlam'
let g:zipPlugin_ext += ',*.xlsx,*.xlsm,*.xlsb,*.xltx,*.xltm,*.xlam,*.crtx'
let g:zipPlugin_ext += ',*.vdw,*.glox,*.gcsx,*.gqsx'

" If docx2txt exists, prevent zip.vim from opening docx files as zip files
if executable('docx2txt') || executable('docx2txt.pl')
  let s:docx2txt = executable('docx2txt') ? 'docx2txt' : 'docx2txt.pl'
  autocmd vimrc BufReadPre *.docx set readonly
  autocmd vimrc BufReadPost *.docx execute '%!' . s:docx2txt
else
  let g:zipPlugin_ext += ',*.docx'
endif

" Ignore things
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj

""""""""""""""""""""""""
" GENERAL FUNCTIONS {{{1
""""""""""""""""""""""""
" Get all windows in all tabs or in a specific tab
" Looks like this functionality does not exist in vim, but might be coming:
" https://groups.google.com/forum/#!topic/vim_dev/rbHieR3rEnc
" FUNCTION: s:bufallwinnr(bufnr, ...) {{{2
function! s:bufallwinnr(bufnr, ...)
  " In order to get all the windows for a buffer, first loop over all the tab
  " pages, get all the windows in each tab page and determine which buffer is
  " displaying in the window.
  let l:tabwinnr = []

  let l:t = 1
  let l:tabnr = get(a:, '1')
  let l:tcount = tabpagenr('$')
  while l:t <= l:tcount
    if l:tabnr > 0 && l:t != l:tabnr
      let l:t = l:t + 1
      continue
    endif

    let l:w = 1
    let l:wcount = tabpagewinnr(l:t, '$')
    while l:w <= l:wcount
      if winbufnr(l:w) == a:bufnr
        call add(l:tabwinnr, [l:t, l:w])
      endif
      let l:w = l:w + 1
    endwhile

    let l:t = l:t + 1
  endwhile

  return l:tabwinnr
endfunction

" FUNCTION: s:find_window(...) {{{2
function! s:find_window(...)
  let l:winvar = get(a:, '1', '')
  if exists(l:winvar)
    return winnr()
  endif
endfunction

" FUNCTION: s:unlet(...) {{{2
function! s:unlet(...)
  let l:prefix = a:1
  for l:var in a:2
    let l:varname = l:prefix.var
    if exists(l:varname)
      execute 'unlet' l:varname
    endif
  endfor
endfunction

" FUNCTION: s:quickfix_combine() {{{2
" Combine location list entries of visible buffers into the quickfix list
function! s:quickfix_combine()
  let l:combined = []
  let l:buflist = uniq(sort(tabpagebuflist()))
  for l:bufnr in l:buflist
      call extend(l:combined, getloclist(l:bufnr))
  endfor

  " Set quickfix list
  call setqflist(l:combined, 'r')

  " Automatically open the quickfix window if it contains any entries
  if !empty(l:combined)
    " Save state
    let l:winstate = winsaveview()
    let l:winnr = winnr()

    " Open the quickfix window
    cwindow 5

    " Restore state if needed
    if l:winnr != winnr()
      wincmd p
      call winrestview(l:winstate)
    endif
  endif
endfunction

" FUNCTION: s:determine_slash() {{{2
function! s:determine_slash() abort
  let s:slash = &shellslash || !exists('+shellslash') ? '/' : '\'
endfunction
call s:determine_slash()

" FUNCTION: s:script_function() {{{2
function! s:script_function(func) abort
  " See http://stackoverflow.com/a/17184285
  return substitute(a:func, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_'),'')
endfunction

""""""""""""""""""""""""
" SETUP PLUGINS {{{1
""""""""""""""""""""""""

"/////////////////////"
" Shared Functions {{{2
"/////////////////////"
let s:active_plugins = {}
function! s:PlugActive(plug) abort
  return get(s:active_plugins, a:plug, has_key(g:plugs, a:plug) &&
        \ isdirectory(expand(join([s:plugin_directory, a:plug], s:slash))))
endfunction

"/////////////////////"
" Zenburn {{{2
"/////////////////////"
" Set colorscheme to zenburn if it exists
if s:PlugActive('Zenburn')
  colorscheme zenburn
endif

"/////////////////////"
" The Silver Searcher {{{2
"/////////////////////"
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

"/////"
" FZF {{{2
"/////"
if s:PlugActive('fzf.vim')
  nnoremap <leader>h :Helptags<CR>
  nnoremap <silent> <C-p> :Files<CR>
endif

"/////////"
" Airline {{{2
"/////////"
if s:PlugActive('vim-airline')
  " See https://github.com/vim-airline/vim-airline/issues/1125
  let g:airline_exclude_preview = 1

  let g:airline_theme = g:colors_name

  " Only enable tmuxline and promptline while installing
  let g:airline#extensions#tmuxline#enabled = g:vim_installing
  let g:airline#extensions#promptline#enabled = g:vim_installing

  " Setup tabline
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#fnamemod = ':.:t'
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let g:airline#extensions#tabline#ignore_bufadd_pat = '\c\vnerd_tree'

  let g:airline_powerline_fonts = !empty($POWERLINE_FONT)
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

  if g:airline_powerline_fonts
    " powerline symbols
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''

    let g:airline#extensions#tabline#left_sep = ''
    let g:airline#extensions#tabline#left_alt_sep = ''
    let g:airline#extensions#tabline#right_sep = ''
    let g:airline#extensions#tabline#right_alt_sep = ''
  else
    " unicode symbols
    let g:airline_left_sep = '»'
    let g:airline_left_alt_sep = '▶'
    let g:airline_right_sep = '«'
    let g:airline_right_alt_sep = '◀'

    let g:airline_symbols.crypt = '🔒'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.maxlinenr = '☰'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.spell = 'Ꞩ'
    let g:airline_symbols.notexists = '∄'
    let g:airline_symbols.whitespace = 'Ξ'

    let g:airline#extensions#tabline#left_sep = '»'
    let g:airline#extensions#tabline#left_alt_sep = '▶'
    let g:airline#extensions#tabline#right_sep = '«'
    let g:airline#extensions#tabline#right_alt_sep = '◀'
  endif
endif

"////////////"
" promptline {{{2
"////////////"
if g:vim_installing && s:PlugActive('promptline.vim')
  " promptline (needs to be after the plugins are activated since it uses a
  " function from promptline which hasn't been sourced yet...)
  let g:promptline_theme = 'airline'
  let g:promptline_powerline_symbols = g:airline_powerline_fonts
  let g:promptline_preset = {
        \ 'a' : [ promptline#slices#host(), promptline#slices#user() ],
        \ 'b' : [ promptline#slices#cwd() ],
        \ 'c' : [ promptline#slices#vcs_branch(), promptline#slices#git_status() ],
        \ 'warn' : [ promptline#slices#last_exit_code() ]
        \}
endif

"////////////"
" tmuxline {{{2
"////////////"
if g:vim_installing && s:PlugActive('tmuxline.vim')
  " tmuxline
  let g:tmuxline_theme = 'airline'
  let g:tmuxline_powerline_separators = g:airline_powerline_fonts
endif

"//////////"
" NERDTree {{{2
"//////////"
if s:PlugActive('nerdtree')
  let g:NERDTreeAutoDeleteBuffer = 1
  let g:NERDTreeMinimalUI = 1
  let g:NERDTreeMouseMode = 2
  let g:NERDTreeShowHidden = 1
  let g:NERDTreeShowHiddenFirst = 1
  let g:NERDTreeQuitOnOpen = 1
  let g:NERDTreeWinSize = 35
  let g:NERDTreeIgnore = [
        \ '\.py[cd]$',
        \ '\~$',
        \ '\.swo$',
        \ '\.swp$',
        \ '\.git',
        \ '\.hg',
        \ '\.svn',
        \ '\.bzr',
        \ '\.map$',
        \ '.DS_Store'
        \]
  let g:NERDTreeIndicatorMapCustom = {
        \ 'Modified' : '✹',
        \ 'Staged' : '✚',
        \ 'Untracked' : '✭',
        \ 'Renamed' : '➜',
        \ 'Unmerged' : '═',
        \ 'Deleted' : '✖',
        \ 'Dirty' : '✗',
        \ 'Clean' : '✔︎',
        \ 'Unknown' : '?'
        \}
  noremap <leader>n :NERDTreeToggle<CR>
  noremap <leader>f :NERDTreeFind<CR>
  autocmd vimrc StdinReadPre * let s:std_in=1
  " If no file or directory arguments are specified, open NERDtree.
  " If a directory is specified as the only argument, open it in NERDTree.
  function! NERDTreeAutoOpen()
    if argc() == 0 && !exists('s:std_in')
      NERDTree
    elseif argc() == 1 && isdirectory(argv(0))
      bd
      exec 'cd' fnameescape(argv(0))
      NERDTree
    end
  endfunction
  autocmd vimrc VimEnter * call NERDTreeAutoOpen()
endif

"/////////"
" Tagbar {{{2
"/////////"
if s:PlugActive('tagbar')
  nnoremap <leader>t :TagbarToggle<CR>
  nnoremap <leader>T :TagbarOpen fj<CR>
endif

"/////////"
" Signify {{{2
"/////////"
if s:PlugActive('vim-signify')
  let g:signify_vcs_list = ['git']
endif

"///////////"
" UltiSnips {{{2
"///////////"
if s:PlugActive('ultisnips')
  " Make <Enter> expand snippets (only when the popup menu is visible),
  " otherwise it simply inserts a carriage return as expected.
  let g:UltiSnipsExpandTrigger = '<Nop>'
	inoremap <expr> <CR> pumvisible() ?
        \ '<C-R>=UltiSnips#ExpandSnippet()<CR>' : '<CR>'

  let g:UltiSnipsJumpForwardTrigger='<TAB>'
  let g:UltiSnipsJumpBackwardTrigger='<S-TAB>'

  autocmd vimrc FileType c UltiSnipsAddFiletypes c
  autocmd vimrc FileType cpp UltiSnipsAddFiletypes cpp
  autocmd vimrc FileType css UltiSnipsAddFiletypes css
  autocmd vimrc FileType go UltiSnipsAddFiletypes go
  autocmd vimrc FileType json UltiSnipsAddFiletypes json
  autocmd vimrc FileType lua UltiSnipsAddFiletypes lua
  autocmd vimrc FileType html UltiSnipsAddFiletypes html
  autocmd vimrc FileType python UltiSnipsAddFiletypes python
  autocmd vimrc FileType xml UltiSnipsAddFiletypes xml
endif

"/////////"
" Neomake {{{2
"/////////"
if s:PlugActive('neomake')
  " For debugging
  "let g:neomake_verbose = 3
  autocmd vimrc ColorScheme,VimEnter *
        \ highlight! link NeomakeErrorSign Error
        \ | highlight! link NeomakeWarningSign Debug

  let g:airline#extensions#neomake#enabled = s:PlugActive('vim-airline')
  autocmd vimrc User NeomakeFinished,NeomakeCountsChanged nested
        \ call s:quickfix_combine()

  let g:neomake_python_pylint_args = [
        \ '--disable=I,R',
        \ '--output-format=text',
        \ '--msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}"',
        \ '--reports=no'
        \ ]
endif

"//////////////////"
" Neomake-Autolint {{{2
"//////////////////"
if s:PlugActive('neomake-autolint')
  " Where to cache temporary files used for linting unwritten buffers.
  let g:neomake_autolint_cachedir = $DOTFILES . '/caches/vim'

  " The number of milliseconds to wait before running another neomake lint
  " over the file.
  let g:neomake_autolint_updatetime = 250

  " Whether to keep the sign column showing all the time. Default to on. With
  " it off it can be quite annoying as the sign column flashes open/closed
  " during autolinting.
  let g:neomake_autolint_sign_column_always = 1
endif

"/////////"
" vim-qf  {{{2
"/////////"
if s:PlugActive('vim-qf')
  nmap <leader>l <Plug>QfLtoggle
  nmap <leader>q <Plug>QfCtoggle

  nmap <leader>j <Plug>QfCnext
  nmap <leader>k <Plug>QfCprevious

  nmap <leader>J <Plug>QfLnext
  nmap <leader>K <Plug>QfLprevious

  let g:qf_mapping_ack_style = 1
  let g:qf_auto_open_loclist = 0
  let g:qf_auto_open_quickfix = 0
endif

"////////////////"
" vim-commentary {{{2
"////////////////"
if s:PlugActive('vim-commentary')
  " example support for apache comments
  "autocmd vimrc FileType apache setlocal commentstring=#\ %s
endif

"///////////////"
" YouCompleteMe {{{2
"///////////////"
if s:PlugActive('YouCompleteMe')
  set completeopt-=preview

  " Vim default is <C-X><C-O> so keep it that way
  let g:ycm_key_invoke_completion = '<Nop>'
  let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']

  function! s:ToggleYcmDoc()
    try
      wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
      silent! YcmCompleter GetDoc
      return
    endtry

    silent! pclose!
  endfunction

  execute printf('inoremap <C-E> <C-R>=execute("call %s()")<CR>',
        \ s:script_function('s:ToggleYcmDoc'))

  nnoremap <leader>yg :YcmCompleter GoTo<CR>
  nnoremap <leader>yd :YcmCompleter GetDoc<CR>
  nnoremap <leader>yr :YcmCompleter GoToReferences<CR>
endif

"//////////////////////"
" vim-multiple-cursors {{{2
"//////////////////////"
if s:PlugActive('vim-multiple-cursors')
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
endif

"////////////"
" vim-rooter {{{2
"////////////"
if s:PlugActive('vim-rooter')
  let g:rooter_use_lcd = 1
  let g:rooter_silent_chdir = 1
endif

"///////////////"
" vim-gutentags  {{{2
"///////////////"
if s:PlugActive('vim-gutentags')
  let g:gutentags_define_advanced_commands = 1

  " Only list files that are actually part of the project
  let g:gutentags_file_list_command = {
        \ 'markers': {
        \ '.git': 'git ls-files',
        \ '.hg': 'hg files',
        \ },
        \ }

  " Update status line if airline is installed
  if s:PlugActive('vim-airline')
    " Add vim-gutentags status
    function! GutentagsStatus(...)
      let w:airline_section_x = get(w:, 'airline_section_x', g:airline_section_x)
      let w:airline_section_x .= g:airline_symbols.space . '%{gutentags#statusline()}'
    endfunction
    call airline#add_statusline_func('GutentagsStatus')
  endif

  " Wrap setup in a function so variables can be local
  function! s:SetupGutenTags()
    if s:PlugActive('vim-rooter')
      let l:git_cmd = 'git -C '
      let l:git_cmd .= expand(s:plugin_directory . '/vim-gutentags')
      let l:git_cmd .= ' rev-parse --abbrev-ref HEAD'

      let l:git_retval = systemlist(l:git_cmd)
      if l:git_retval[0] ==# 'buffer-tagfiles'
        function! GutentagsGetTagfile(path)
          let l:project_root = FindRootDirectory()
          if !empty(l:project_root)
            let b:gutentags_root = l:project_root
            if isdirectory(expand(l:project_root . '/.git'))
              let b:gutentags_tagfile = '.git/tags'
              return 1
            endif
          endif

          return 0
        endfunction

        let g:gutentags_init_user_func = 'GutentagsGetTagfile'
      else
        " Use a single cache directory.
        " 'ctags_cleanup' script can remove orphaned tags files
        let g:gutentags_cache_dir = $DOTFILES . '/caches/ctags'

        " vim-gutentags expects a function which takes one parameter to it
        " so wrap the vim-rooter function which does not take a path.
        function! GutentagsProjectRoot(path)
          return FindRootDirectory()
        endfunction

        let g:gutentags_project_root_finder = 'GutentagsProjectRoot'
      endif
    else
      " Use a single cache directory.
      " 'ctags_cleanup' script can remove orphaned tags files
      let g:gutentags_cache_dir = $DOTFILES . '/caches/ctags'
    endif
  endfunction

  call s:SetupGutenTags()

  " Exuberant ctags has more limited tagging support than Universal ctags.
  " Since Universal ctags does not have an initial release yet add support for
  " additional languages using overrides as necessary.
  if executable('gotags')
    call add(g:gutentags_project_info, {'type': 'go', 'glob': '*.go'})
    let g:gutentags_ctags_executable_go = 'gotags'
  endif
endif

"//////////"
" undotree {{{2
"//////////"
if s:PlugActive('undotree')
  nnoremap <silent> <leader>u :UndotreeToggle<CR>
endif

"////////////////"
" vim-easy-align {{{2
"////////////////"
if s:PlugActive('vim-easy-align')
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
endif

"///////////////"
" incsearch.vim {{{2
"///////////////"
if s:PlugActive('incsearch.vim')
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

  let g:incsearch#auto_nohlsearch = 1
  map n  <Plug>(incsearch-nohl-n)
  map N  <Plug>(incsearch-nohl-N)
  map *  <Plug>(incsearch-nohl-*)
  map #  <Plug>(incsearch-nohl-#)
  map g* <Plug>(incsearch-nohl-g*)
  map g# <Plug>(incsearch-nohl-g#)
endif

"/////////////////////"
" incsearch-fuzzy.vim {{{2
"/////////////////////"
if s:PlugActive('incsearch-fuzzy.vim')
  function! s:config_fuzzyall(...) abort
    return extend(copy({
          \   'converters': [
          \     incsearch#config#fuzzy#converter(),
          \     incsearch#config#fuzzyspell#converter()
          \   ],
          \ }), get(a:, 1, {}))
  endfunction

  noremap <silent><expr> z/ incsearch#go(<SID>config_fuzzyall())
  noremap <silent><expr> z? incsearch#go(<SID>config_fuzzyall({'command': '?'}))
  noremap <silent><expr> zg? incsearch#go(<SID>config_fuzzyall({'is_stay': 1}))
endif

"//////////////////////////"
" incsearch-easymotion.vim {{{2
"//////////////////////////"
if s:PlugActive('incsearch-easymotion.vim')
  function! s:config_easyfuzzymotion(...) abort
    return extend(copy({
          \   'converters': [incsearch#config#fuzzy#converter()],
          \   'modules': [incsearch#config#easymotion#module()],
          \   'keymap': {"\<CR>": '<Over>(easymotion)'},
          \   'is_expr': 0,
          \   'is_stay': 1
          \ }), get(a:, 1, {}))
  endfunction

  noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
endif

"////////////////"
" easymotion.vim {{{2
"////////////////"
if s:PlugActive('vim-easymotion')
  nmap F <Plug>(easymotion-s)
endif

"////////////"
" indentLine {{{2
"////////////"
if s:PlugActive('indentLine')
  let g:indentLine_fileTypeExclude=['text', 'help']
endif

" vim: set sw=2 sts=2 fdm=marker:
