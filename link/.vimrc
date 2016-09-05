""""""""""""""""""""""""
" GLOBAL VARIABLES
""""""""""""""""""""""""
" Only allow some configuration settings during install
let g:vim_installing = $VIM_INSTALLING

" For some reason doing nvim +PluginInstall errors for vim-plug and
" vim-sensible if I don't do this.
let g:syntax_on=g:vim_installing

" See if vim is running in a tmux session
let g:tmux = $TMUX

" Useful OS detection
if has("unix")
  let s:uname = system("uname -a")
  let g:osx = s:uname =~? "darwin"
  let g:ubuntu = s:uname =~? "ubuntu"
endif

" Where plugins get installed
let b:plugin_directory = '~/.vim/plugged'

""""""""""""""""""""""""
" Plugins
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

call plug#begin(b:plugin_directory)
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
Plug 'neomake/neomake'
Plug 'sheerun/vim-polyglot'
Plug 'Yggdroot/indentLine'

" Tags
if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'majutsushi/tagbar'
endif

" Completions
if executable('go')
  Plug 'fatih/vim-go', { 'for': 'go' }
endif
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Valloric/YouCompleteMe', { 'do': b:ycm_install_cmd }
      \ | Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}

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
Plug 'christoomey/vim-tmux-navigator'

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

" Dev icons (must be last)
" https://github.com/ryanoasis/vim-devicons#step-3-configure-vim
if !empty($NERD_FONT)
  Plug 'ryanoasis/vim-devicons'
endif
call plug#end()

""""""""""""""""""""""""
" GENERAL
""""""""""""""""""""""""
" Local dirs
set backupdir=$DOTFILES/caches/vim
set directory=$DOTFILES/caches/vim

if has("persistent_undo")
  set undodir=$DOTFILES/caches/vim
  set undofile
endif

" Create vimrc autocmd group and remove any existing vimrc autocmds,
" in case .vimrc is re-sourced.
augroup vimrc
  autocmd!
augroup END

""""""""""""""""""""""""
" VISUAL SETTINGS
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

" Set colorscheme to zenburn if it exists
if isdirectory(expand(b:plugin_directory . '/Zenburn'))
  colorscheme zenburn
else
  colorscheme desert
endif
syntax enable

" There is a potential for screen flicker, these next two settings
" should help address any screen flicker issues whether running in tmux or
" not.

" https://sunaku.github.io/vim-256color-bce.html
if &term =~ '256color'
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
" USER INTERFACE
""""""""""""""""""""""""
set splitbelow " New split goes bottom
set splitright " New split goes right
set hidden " When a buffer is brought to foreground, remember undo history and marks.
set report=0 " Show all changes.
set mouse=a " Enable mouse in all modes.
set timeout
set timeoutlen=250
if has('mouse_sgr')
  set ttymouse=sgr
endif

" Override default in sensible.vim, do not include context above/below cursor
" when scrolling. Have to implement it this way because sensible.vim will
" set scrolloff=1 if it is 0, which is the value I want and it cannot be
" overridden due to the order of sourcing sensible.vim files.
autocmd vimrc VimEnter * :set scrolloff=0

""""""""""""""""""""""""
" FORMATTING
""""""""""""""""""""""""
set shiftwidth=2 " The # of spaces for indenting.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=2 " Tabs indent only 2 spaces
set expandtab " Expand tabs to spaces
set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command.
set hlsearch " Highlight searches

""""""""""""""""""""""""
" KEYMAPPINGS
""""""""""""""""""""""""
" Change mapleader
let mapleader=","

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
" FILE TYPES
""""""""""""""""""""""""
autocmd vimrc BufRead .vimrc,*.vim set keywordprg=:help
autocmd vimrc BufRead,BufNewFile *.md set filetype=markdown
autocmd vimrc BufRead,BufNewFile *.tmpl set filetype=html

" Ignore things
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj

""""""""""""""""""""""""
" GENERAL FUNCTIONS
""""""""""""""""""""""""
" Get all windows in all tabs or in a specific tab
" Looks like this functionality does not exist in vim, but might be coming:
" https://groups.google.com/forum/#!topic/vim_dev/rbHieR3rEnc
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

function! s:find_window(...)
  let l:winvar = get(a:, '1', '')
  if exists(l:winvar)
    return winnr()
  endif
endfunction

function! s:unlet(...)
  let l:prefix = a:1
  for var in a:2
    let l:varname = l:prefix.var
    if exists(l:varname)
      execute 'unlet' l:varname
    endif
  endfor
endfunction

function! s:funcref(func)
  return type(a:func) == type('') ? function(a:func) : func
endfunction

function! s:repeat_while_true(func, ...)
  let l:Func = s:funcref(a:func)
  let l:continue = call(l:Func, a:000)
  while l:continue != v:null
    let l:continue = call(l:Func, a:000)
  endwhile
endfunction

""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""

"/////////////////////"
" The Silver Searcher "
"/////////////////////"
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " bind k to grep word under cursor
  noremap <leader>k :lgrep! "\b<C-R><C-W>\b"<CR>:lwindow<CR>

  " New command :Ag which takes standard ag arguments
  command! -nargs=+ -complete=file -bar Ag silent! lgrep! <args>|lwindow|redraw!
endif

"/////////////////////"
" FZF
"/////////////////////"
if executable('fzf')
  nnoremap <leader>h :Helptags<CR>
  nnoremap <silent> <C-p> :Files<CR>
endif

"/////////"
" Airline "
"/////////"
if isdirectory(expand(b:plugin_directory . '/vim-airline'))
  " Let other plugins know vim-airline is installed
  let g:airline_installed = 1

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
" promptline "
"////////////"
if g:vim_installing && isdirectory(expand(b:plugin_directory . '/promptline.vim'))
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
" tmuxline "
"////////////"
if g:vim_installing && isdirectory(expand(b:plugin_directory . '/tmuxline.vim'))
  " tmuxline
  let g:tmuxline_theme = 'airline'
  let g:tmuxline_powerline_separators = g:airline_powerline_fonts
endif

"//////////"
" NERDTree "
"//////////"
if isdirectory(expand(b:plugin_directory . '/nerdtree'))
  let NERDTreeAutoDeleteBuffer = 1
  let NERDTreeMinimalUI = 1
  let NERDTreeMouseMode = 2
  let NERDTreeShowHidden = 1
  let NERDTreeShowHiddenFirst = 1
  let NERDTreeQuitOnOpen = 1
  let NERDTreeWinSize = 35
  let NERDTreeIgnore = [
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
" Tagbar
"/////////"
if isdirectory(expand(b:plugin_directory . '/tagbar'))
  nnoremap <leader>t :TagbarToggle<CR>
endif

"/////////"
" Signify "
"/////////"
if isdirectory(expand(b:plugin_directory . '/vim-signify'))
  let g:signify_vcs_list = ['git']
endif

"///////////"
" UltiSnips "
"///////////"
if isdirectory(expand(b:plugin_directory . '/ultisnips'))
  let g:UltiSnipsJumpForwardTrigger='<c-b>'
  let g:UltiSnipsJumpBackwardTrigger='<c-z>'
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

"///////////"
" Neomake "
"///////////"
if isdirectory(expand(b:plugin_directory . '/neomake'))
  " Only enable my makeshift neomake ide if neomake has
  " asynchronous job support which makes the lint
  " as you type approach work without constant pauses.
  let g:enable_neomake_ide = neomake#has_async_support()

  " The number of milliseconds to wait before running
  " another neomake lint over the file. If you set
  " this too low it will end up having a lot of flicker
  " which can be distracting.
  let g:neomake_ide_updatetime = 3000

  " Automatic location list management (use location list for file mode)
  " 0: No automatic management
  " 1: 'Smart' management (open/close single location list below current window)
  " 2: 'Smart' management (open/close all location lists below corresponding window)
  " 3: 'Smart' management + always open location list
  let g:neomake_ide_loclist_management = 0

  " Automatic quickfix list management (use location list for file mode)
  " 0: No automatic management
  " 1: Open/close quickfix list
  " 2: Always open quickfix list
  let g:neomake_ide_quickfix_management = 2

  " neomake defaults for quickfix/location list management
  let g:neomake_open_list = 0
  let g:neomake_list_height = 5

  " For debugging
  "let g:neomake_verbose = 3

  " Constants
  let s:neomake_msg_noerr = "No errors"
  lockvar s:neomake_msg_noerr

  let s:neomake_msg_linting = "Linting..."
  lockvar s:neomake_msg_linting

  let s:neomake_msgs = [s:neomake_msg_noerr, s:neomake_msg_linting]
  lockvar s:neomake_msgs

  let s:neomake_buffers = {}
  function! s:neomake_buffer_name(basename)
    let l:fname = expand(a:basename.':p:t')
    let l:tmpdir = fnamemodify(tempname(), ':p:h')
    return fnameescape(join([l:tmpdir, l:fname], '/'))
  endfunction

  let s:neomake_makers_by_buffer = {}
  function! s:neomake_get_makers(bufnr)
    if !has_key(s:neomake_makers_by_buffer, a:bufnr)
      let s:neomake_makers_by_buffer[a:bufnr] = {}
    endif
    let l:makers_for_buffer = s:neomake_makers_by_buffer[a:bufnr]

    let l:ft = &filetype
    let l:makers = []
    let l:maker_names = neomake#GetEnabledMakers(l:ft)
    for maker_name in l:maker_names
      let l:maker = neomake#GetMaker(maker_name, l:ft)
      let l:full_maker_name = string(a:bufnr).'_'.l:ft.'_'.maker_name

      " Some makers (like the default go makers) operate on an entire
      " directory which breaks for this file based linting approach.
      " If 'append_file' exists and is 0 then this is a maker which
      " operates on the directory rather than the file so skip it.
      if exists('l:maker') && get(l:maker, 'append_file', 1)
        if !exists('l:makers_for_buffer[l:full_maker_name]')
          " Store off the original values
          let l:maker.obufnr = a:bufnr
          if exists('l:maker.postprocess')
            let l:maker.original = s:funcref(l:maker.postprocess)
          endif

          " Wrap the existing post process to do extra processing
          " after it completes
          function! l:maker.postprocess(entry)
            " If call the original postprocess if it exists
            if exists('self.original')
              call self.original(a:entry)
            endif

            " The neomake job was executed on the temp buffer, so fix up
            " the location list entry to point to the real buffer.
            let a:entry.bufnr = self.obufnr

            " If no error type is provided default to error
            if !exists('a:entry.type') || empty(a:entry.type)
              let a:entry.type = 'E'
            endif
          endfunction

          let l:maker.name = l:full_maker_name
          let l:makers_for_buffer[l:full_maker_name] = l:maker
        endif

        call add(l:makers, l:maker)
      endif
    endfor

    return l:makers
  endfunction

  function! s:neomake_quickfix_clear(bufnr)
    if !get(g:, 'neomake_ide_quickfix_management')
      return
    endif

    let l:updated = [{'bufnr': 1, 'text': s:neomake_msg_linting}]
    let l:qflist = getqflist()
    for entry in l:qflist
      if entry.bufnr != a:bufnr && index(s:neomake_msgs, entry.text) < 0
        call add(l:updated, entry)
      endif
    endfor
    call setqflist(l:updated, 'r')

    call s:neomake_manage_quickfix(a:bufnr)
  endfunction

  function! s:neomake_manage_quickfix(bufnr, ...)
    if !get(g:, 'neomake_ide_quickfix_management')
      return
    endif

    let l:bufinfo = get(s:neomake_buffers, a:bufnr, {})
    if empty(l:bufinfo)
      return
    endif

    let l:updated = []
    let l:qflist = getqflist()
    let l:buflist = tabpagebuflist()
    for entry in l:qflist
      if entry.bufnr != a:bufnr
            \ && index(l:buflist, entry.bufnr) >= 0
            \ && index(s:neomake_msgs, entry.text) < 0
        call add(l:updated, entry)
      endif
    endfor

    let l:leave = get(a:, '1')
    if !l:leave
      let l:updated = extend(l:updated, l:bufinfo.qflist)
    endif

    if empty(l:updated)
      let l:updated = [{'bufnr': 1, 'text': s:neomake_msg_noerr}]
    endif
    call setqflist(l:updated, 'r')

    let l:winnr = winnr()
    if get(g:, 'neomake_ide_quickfix_management') < 2
      execute 'botright cwindow' get(g:, 'neomake_list_height', 10)
    else
      execute 'botright copen' get(g:, 'neomake_list_height', 10)
    endif

    if l:winnr != winnr()
      wincmd p
    endif
  endfunction

  " The reason the location list management is setup the way it is has to do
  " with the difficulty of window management with (neo)vim. Once that issue is
  " addressed this can be revisited:
  " https://github.com/neovim/neovim/issues/3933
  " http://tarruda.github.io/articles/neovim-smart-ui-protocol/
  function! s:neomake_manage_loclists(bufnr, ...)
    if !get(g:, 'neomake_ide_loclist_management')
      return
    endif

    let l:bufinfo = get(s:neomake_buffers, a:bufnr, {})
    if empty(l:bufinfo)
      return
    endif

    if exists('s:neomake_managing_loclists')
      call neomake#utils#ErrorMessage("IDE: already managing location lists")
      return
    endif

    let w:neomake_loclist_winnr = 1
    let s:neomake_managing_loclists = 1
    call s:neomake_windo('s:neomake_loclist_set', a:bufnr, l:bufinfo.qflist)
    call s:repeat_while_true('s:neomake_windo', 's:neomake_loclist_close')
    call s:repeat_while_true('s:neomake_windo', 's:neomake_loclist_open')
    let l:winnr =  s:neomake_windo('s:find_window', 'w:neomake_loclist_winnr')
    call s:neomake_windo('s:unlet', 'w:neomake_loclist_', ['opened', 'closed', 'winnr'])
    unlet s:neomake_managing_loclists

    if l:winnr != v:null
      call neomake#utils#DebugMessage("IDE: switching to window: ".l:winnr)
      execute string(l:winnr).'wincmd w'
    endif
  endfunction

  function! s:neomake_windo(...)
    let l:ignorelist = &eventignore
    let &eventignore = "WinEnter,WinLeave,BufEnter,BufLeave"

    " Move to top-right window
    wincmd t

    " Loop over all windows
    let l:w = 1
    let l:wcount = winnr('$')
    let l:Func = s:funcref(a:1)
    while v:true
      let l:retval = call(l:Func, a:000[1:])
      if l:retval != v:null
        break
      endif

      let l:w = l:w + 1
      if l:w > winnr('$')
        break
      endif

      " Move to next window
      wincmd w
    endwhile

    let &eventignore = l:ignorelist
    return l:retval
  endfunction

  function! s:neomake_loclist_set(...)
    let l:bufnr = get(a:, '1')
    let l:loclist = get(a:, '2', [])
    if l:bufnr == bufnr('%')
      call setloclist(0, l:loclist, 'r')
    endif
  endfunction

  function! s:neomake_loclist_close(...)
    let l:empty_only = get(a:, '1')
    if !exists('w:neomake_loclist_closed')
          \ && (!l:empty_only || len(getloclist(0)) == 0)
      let w:neomake_loclist_closed = 1

      lclose
      return 1
    endif
  endfunction

  function! s:neomake_loclist_open(...)
    let l:length = len(getloclist(0))
    let l:manage = get(g:, 'neomake_ide_loclist_management')

    " If only the current loclist should be opened
    let l:open_current = (l:manage == 1)
          \ && exists('w:neomake_loclist_winnr')
          \ && l:length > 0

    " If any non-empty loclist should be opened
    let l:open_nonempty = (l:manage == 2)
          \ && l:length > 0

    " If loclist should always be opened
    let l:open_always = (l:manage == 3)

    if (l:open_current || l:open_nonempty || l:open_always) && !exists('w:neomake_loclist_opened')
      let w:neomake_loclist_opened = 1

      if l:length == 0
        call setloclist(0, [{'bufnr': bufnr('%'), 'text': s:neomake_msg_noerr}], 'r')
        silent! execute 'lwindow' get(g:, 'neomake_list_height', 10)
      endif

      lopen
      return 1
    endif
  endfunction

  function! s:neomake_loclist_setup(bufnr)
    if exists('w:neomake_loclist_setup') || !has_key(s:neomake_buffers, a:bufnr)
      return
    endif

    " Not entirely certain why, but airline makes my neomake ide extremely
    " slow; disable it in any neomake ide windows. I profiled it and noticed
    " that the palette dict in the airline#highlighter#highlight function
    " seemed to be larger for some reason (at least the for loop had more
    " calls with it enabled vs. disabled). I believe it has something to do
    " with the creation/deletion of location list windows that neomake ide is
    " constantly managing.
    let w:airline_disabled = 1
    let w:neomake_loclist_setup = 1
    call s:neomake_manage_loclists(a:bufnr)
  endfunction

  function! <sid>neomake_window_moved()
    call s:neomake_manage_loclists(bufnr('%'))
  endfunction

  function! s:neomake_setup_ide()
    let l:bufnr = bufnr('%')
    if has_key(s:neomake_buffers, l:bufnr)
      " Make sure the location list is opened or closed as necessary
      call s:neomake_manage_quickfix(l:bufnr)
      call s:neomake_manage_loclists(l:bufnr)
      return
    endif

    let l:makers =  s:neomake_get_makers(l:bufnr)
    if len(l:makers) > 0
      " This is a filetype with makers
      let s:neomake_buffers[l:bufnr] = {
            \ 'bufnr': l:bufnr,
            \ 'file': s:neomake_buffer_name('%'),
            \ 'force': 0,
            \ 'job_ids': [],
            \ 'makers': l:makers,
            \ 'qflist': []
            \ }

      " Make sure the sign column is always showing
      execute 'sign place 999999 line=1 name=neomake_invisible buffer='.l:bufnr

      if get(g:, 'neomake_ide_loclist_management') == 3
        " Make sure the location list is always showing
        call setloclist(0, [{'bufnr': l:bufnr, 'text': s:neomake_msg_noerr}], 'r')
        silent! execute 'lwindow' get(g:, 'neomake_list_height', 10)
              \ | lopen
              \ | wincmd p
      endif

      " Disable airline in the window, see s:neomake_loclist_setup for more
      " details.
      let w:airline_disabled = 1

      " Run neomake on the initial load of the buffer to check for errors
      call s:neomake_onchange(l:bufnr)

      if get(g:, 'neomake_ide_loclist_management')
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Window Creation Handling
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        autocmd s:neomake WinEnter <buffer>
              \ call s:neomake_loclist_setup(expand('<abuf>'))

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Window Close Handling
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Closing a neomake buffer
        autocmd s:neomake WinLeave <buffer>
              \ if get(g:, 'neomake_ide_loclist_management') > 1
              \ | let s:neomake_ide_wincount = winnr('$')
              \ | endif

        " Closing a location list buffer
        autocmd s:neomake WinLeave *
              \ if &buftype == 'quickfix'
              \ | let s:neomake_ide_wincount = winnr('$')
              \ | endif

        autocmd s:neomake WinEnter *
              \ if get(g:, 'neomake_ide_loclist_management') == 1
              \ || get(s:, 'neomake_ide_wincount', winnr('$')) != winnr('$')
              \ | call s:neomake_manage_loclists(expand('<abuf>'))
              \ | endif
            \ | unlet! s:neomake_ide_wincount
      endif

      if get(g:, 'neomake_ide_loclist_management')
            \ || get(g:, 'neomake_ide_quickfix_management')
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Buffer Close Handling
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""
        autocmd s:neomake BufWinLeave <buffer>
              \ call s:neomake_manage_quickfix(expand('<abuf>'), 1)
              \ | call s:neomake_manage_loclists(expand('<abuf>'))
      endif

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Text Changed Handling
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      autocmd s:neomake TextChangedI,CursorHoldI <buffer>
            \ call s:neomake_onchange(bufnr('%'))

      autocmd s:neomake TextChanged,InsertLeave,CursorHold <buffer>
            \ call s:neomake_onchange(bufnr('%'), 1)
    endif
  endfunction

  function! s:neomake_running(bufinfo)
    " Check for manually initiated jobs
    let l:jobs = neomake#GetJobs()
    for jobinfo in values(l:jobs)
      if jobinfo.bufnr == a:bufinfo.bufnr
        return 1
      endif
    endfor

    return 0
  endfunction

  function! s:neomake_onchange(bufnr, ...)
    " Only run if the buffer has been modified
    if b:changedtick == get(b:, 'neomake_changedtick', -1)
      return
    endif

    " Get the appropriate buffer info by filename
    let l:bufinfo = s:neomake_buffers[a:bufnr]

    " See if a force update is specified. If there is an external
    " (not initiated by the IDE) job pending it will run after the
    " current job completes.
    let l:bufinfo.force = l:bufinfo.force || get(a:, '1')

    " Only run neomake if there isn't already a job running for this buffer.
    if s:neomake_running(l:bufinfo)
      return
    endif

    " Get current time and elasped time since last update
    let l:time = reltime()
    if has_key(l:bufinfo, 'updated')
      let l:updated = l:bufinfo.updated
      let l:elapsed = 1000 * str2float(reltimestr(reltime(l:updated, l:time)))
    else
      let l:elapsed = g:neomake_ide_updatetime
    endif

    " If enough time has passed since the last update or forcing an update.
    if !l:bufinfo.force && l:elapsed < g:neomake_ide_updatetime
      return
    endif
    let l:bufinfo.force = 0

    " Cancel any in progress jobs
    for job_id in l:bufinfo.job_ids
      try
        " TODO: Cancel job does not appear to be working. I'll submit
        " a patch, but in the meantime manually cancel the job.
        " call neomake#CancelJob(job_id)
        call jobstop(job_id)
      catch /^Vim\%((\a\+)\)\=:E900/
        " Ignore invalid job id errors. Happens when the job is done,
        " but on_exit hasn't been called yet.
      endtry
    endfor

    " Update the time
    let b:neomake_changedtick = b:changedtick
    let l:bufinfo.updated = l:time

    " Need the original filetype in order to set the new buffer to the
    " correct filetype (it might not be automatically detected)
    let l:ft = &filetype

    " Store off current state
    let l:winstate = winsaveview()

    " Clear previous state
    call s:neomake_quickfix_clear(a:bufnr)
    call neomake#signs#ResetFile(a:bufnr)
    call neomake#statusline#ResetCountsForBuf(a:bufnr)

    " Write the temporary file and open it
    let l:tmpfile = l:bufinfo.file
    silent! call writefile(getline(1, '$'), l:tmpfile)
    silent! execute 'edit' l:tmpfile

    " Make sure it is unlisted and has the proper filetype
    silent! execute 'setlocal bufhidden=hide noswapfile nobuflisted filetype='.l:ft

    " Run neomake in file mode with the updated makers
    " Do not run silent incase of verbose output (g:neomake_verbose)
    let l:bufinfo.job_ids = neomake#Make(1,
          \ l:bufinfo.makers, function('s:neomake_job_completed'))

    " Edit the previous buffer (the original file)
    silent! execute 'edit' fnameescape(expand('#'))

    " Restore winstate and redraw
    silent! call winrestview(l:winstate)
  endfunction

  function! s:neomake_job_completed(info)
    " There are more jobs for this maker so wait for them to complete.
    if a:info.has_next
      return
    endif

   " The maker name includes the bufnr, so coerce the string into
   " a number ("1_string" + 0 == 1)
   let s:neomake_completed_bufnr = a:info.name + 0
  endfunction

  function! s:neomake_complete()
    " This completion is not from the IDE
    if !exists('s:neomake_completed_bufnr')
      return
    endif

    " Get the original bufinfo
    let l:bufnr = s:neomake_completed_bufnr
    let l:bufinfo = s:neomake_buffers[l:bufnr]
    unlet s:neomake_completed_bufnr

    " Set the quickfix/location list
    let l:bufinfo.qflist = getloclist(0)

    " Clear out the list of job ids since they have all finished
    let l:bufinfo.job_ids = []
    call neomake#CleanOldFileSignsAndErrors(l:bufnr)

    " Make sure the location list is opened or closed as necessary
    call s:neomake_manage_loclists(l:bufnr)

    " Make sure the quickfix list is opened or closed as necessary
    call s:neomake_manage_quickfix(l:bufnr)

    if l:bufinfo.force
      " If there is a force update pending then go ahead and trigger it
      call s:neomake_onchange(l:bufnr, l:bufinfo.force)
    endif
  endfunction

  function! s:neomake_remove(file)
    " Since this is called for every BufWipeout ensure it is a tracked buffer
    let l:bufnr = bufnr(a:file)
    let l:bufinfo = get(s:neomake_buffers, l:bufnr, {})

    if len(l:bufinfo) > 0
      call delete(l:bufinfo.file)
      call remove(s:neomake_buffers, l:bufnr)
    endif
  endfunction

  function! s:neomake_remove_all()
    for bufinfo in values(s:neomake_buffers)
      call delete(bufinfo.file)
    endfor
    let s:neomake_buffers = {}
  endfunction

  " Create neomake autocmd group and remove any existing neomake autocmds,
  " in case .vimrc is re-sourced.
  augroup s:neomake
    autocmd!
  augroup END

  if get(g:, 'enable_neomake_ide')
    " Map all the window moving commands to also call window moved
    nnoremap <silent> <C-W>r :wincmd r<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W>R :wincmd R<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W><C-R> :wincmd R<CR> :call <sid>neomake_window_moved()<CR>

    nnoremap <silent> <C-W>x :wincmd x<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W><C-X> :wincmd X<CR> :call <sid>neomake_window_moved()<CR>

    nnoremap <silent> <C-W>J :wincmd J<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W>K :wincmd K<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W>L :wincmd L<CR> :call <sid>neomake_window_moved()<CR>
    nnoremap <silent> <C-W>H :wincmd H<CR> :call <sid>neomake_window_moved()<CR>

    " Auto commands for managing the IDE
    autocmd s:neomake BufWinEnter * call s:neomake_setup_ide()
    autocmd s:neomake User NeomakeFinished nested call s:neomake_complete()
    autocmd s:neomake VimLeavePre * call s:neomake_remove_all()
    autocmd s:neomake BufWipeout * call s:neomake_remove('<afile>')

    " If the quickfix list should be shown
    if get(g:, 'neomake_ide_quickfix_management') == 2
      " Make sure the quickfix window is always showing
      call setqflist([{'bufnr': 1, 'text': s:neomake_msg_noerr}], 'r')
      silent! execute 'botright cwindow' get(g:, 'neomake_list_height', 10)
            \ | execute 'botright copen' get(g:, 'neomake_list_height', 10)
            \ | wincmd p
    endif
  endif
endif

"////////////////"
" vim-commentary "
"////////////////"
if isdirectory(expand(b:plugin_directory . '/vim-commentary'))
  " example support for apache comments
  "autocmd vimrc FileType apache setlocal commentstring=#\ %s
endif

"///////////////"
" YouCompleteMe "
"///////////////"
if isdirectory(expand(b:plugin_directory . '/YouCompleteMe'))
  let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']
endif

"//////////////////////"
" vim-multiple-cursors "
"//////////////////////"
if isdirectory(expand(b:plugin_directory . '/vim-multiple-cursors'))
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

"///////////////"
" vim-rooter "
"///////////////"
if isdirectory(expand(b:plugin_directory . '/vim-rooter'))
  " Let other plugins know vim-rooter is installed
  let g:rooter_installed = 1

  let g:rooter_use_lcd = 1
endif

"///////////////"
" vim-gutentags "
"///////////////"
if isdirectory(expand(b:plugin_directory . '/vim-gutentags'))
  " For now always set the tags file to .git/tags
  " Revisit this after the following issue is addressed:
  " https://github.com/ludovicchabant/vim-gutentags/issues/93
  let g:gutentags_tagfile='.git/tags'

  if get(g:, 'airline_installed')
    " Add vim-gutentags status
    function! GutentagsStatus(...)
      let w:airline_section_x = get(w:, 'airline_section_x', g:airline_section_x)
      let w:airline_section_x .= g:airline_symbols.space . '%{gutentags#statusline()}'
    endfunction
    call airline#add_statusline_func('GutentagsStatus')
  endif

  " vim-gutentags expects a function which takes one parameter to it
  " so wrap the vim-rooter function which does not take a path.
  if get(g:, 'rooter_installed')
    function! GutentagsProjectRoot(path)
      return FindRootDirectory()
    endfunction

    let g:gutentags_project_root_finder='GutentagsProjectRoot'
  endif

  " Exuberant ctags has more limited tagging support than Universal ctags.
  " Since Universal ctags does not have an initial release yet add support for
  " additional languages using overrides as necessary.
  if executable('gotags')
    call add(g:gutentags_project_info, {'type': 'go', 'glob': '*.go'})
    let g:gutentags_ctags_executable_go = 'gotags'
  endif
endif

"//////////"
" undotree "
"//////////"
if isdirectory(expand(b:plugin_directory . '/undotree'))
  nnoremap <silent> <leader>u :UndotreeToggle<CR>
endif

"////////////////"
" vim-easy-align "
"////////////////"
if isdirectory(expand(b:plugin_directory . '/vim-easy-align'))
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xnoremap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nnoremap ga <Plug>(EasyAlign)
endif

"///////////////"
" incsearch.vim "
"///////////////"
"Plug 'haya14busa/' | Plug 'haya14busa/incsearch-fuzzy.vim'
if isdirectory(expand(b:plugin_directory . '/incsearch.vim'))
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
" incsearch-fuzzy.vim "
"/////////////////////"
if isdirectory(expand(b:plugin_directory . '/incsearch-fuzzy.vim'))
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
" incsearch-easymotion.vim "
"//////////////////////////"
if isdirectory(expand(b:plugin_directory . '/incsearch-easymotion.vim'))
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
" easymotion.vim "
"////////////////"
if isdirectory(expand(b:plugin_directory . '/easymotion.vim'))
  nnoremap <leader>s <Plug>(easymotion-s)
endif
