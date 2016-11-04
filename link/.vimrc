""""""""""""""""""""""""
" GLOBAL VARIABLES
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
Plug 'dojoteef/neomake', { 'branch': 'shellcheck_improvements' }
Plug 'sheerun/vim-polyglot'
Plug 'Yggdroot/indentLine'
Plug 'ynkdir/vim-vimlparser', { 'for': 'vim' }
      \ | Plug 'syngan/vim-vimlint', { 'for': 'vim' }
Plug 'junegunn/vader.vim', { 'on': 'Vader', 'for': 'vader' }

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
if isdirectory(expand(s:plugin_directory . '/Zenburn'))
  colorscheme zenburn
else
  colorscheme desert
endif
syntax enable

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

" Automatically combine location list entries into the quickfix list
autocmd vimrc BufWinEnter,BufWinLeave <buffer> call s:quickfix_combine()

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
" FILE TYPES
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
  for l:var in a:2
    let l:varname = l:prefix.var
    if exists(l:varname)
      execute 'unlet' l:varname
    endif
  endfor
endfunction

function! s:funcref(func)
  return type(a:func) == type('') ? function(a:func) : a:func
endfunction

function! s:repeat_while_true(func, ...)
  let l:Func = s:funcref(a:func)
  let l:continue = call(l:Func, a:000)
  while l:continue != v:null
    let l:continue = call(l:Func, a:000)
  endwhile
endfunction

" See http://stackoverflow.com/a/17184285
function! s:script_function(name)
  return substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_'),'')
endfunction

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

    " Open/close quickfix window
    cwindow 5

    " Restore state if needed
    if l:winnr != winnr()
      wincmd p
      call winrestview(l:winstate)
    endif
  endif
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
if isdirectory(expand(s:plugin_directory . '/vim-airline'))
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
if g:vim_installing && isdirectory(expand(s:plugin_directory . '/promptline.vim'))
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
if g:vim_installing && isdirectory(expand(s:plugin_directory . '/tmuxline.vim'))
  " tmuxline
  let g:tmuxline_theme = 'airline'
  let g:tmuxline_powerline_separators = g:airline_powerline_fonts
endif

"//////////"
" NERDTree "
"//////////"
if isdirectory(expand(s:plugin_directory . '/nerdtree'))
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
" Tagbar
"/////////"
if isdirectory(expand(s:plugin_directory . '/tagbar'))
  nnoremap <leader>t :TagbarToggle<CR>
endif

"/////////"
" Signify "
"/////////"
if isdirectory(expand(s:plugin_directory . '/vim-signify'))
  let g:signify_vcs_list = ['git']
endif

"///////////"
" UltiSnips "
"///////////"
if isdirectory(expand(s:plugin_directory . '/ultisnips'))
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
if isdirectory(expand(s:plugin_directory . '/neomake'))
  " Only enable my makeshift neomake autolint if neomake has
  " asynchronous job support which makes the lint
  " as you type approach work without constant pauses.
  let g:neomake_autolint = neomake#has_async_support()

  " Where to cache temporary files used for linting
  " unwritten buffers.
  let g:neomake_autolint_cachedir = $DOTFILES . '/caches/vim'

  " The number of milliseconds to wait before running
  " another neomake lint over the file.
  let g:neomake_autolint_updatetime = 250

  " For debugging
  "let g:neomake_verbose = 3

  let s:neomake_buffers = {}
  function! s:neomake_temp_filename(basename)
    let l:fname = expand(a:basename.':p:t')
    let l:tmpdir = fnamemodify(get(g:, 'neomake_autolint_cachedir', tempname()), ':p:h')
    return fnameescape(join([l:tmpdir, l:fname], '/'))
  endfunction

  " Setup per buffer makers that use a temporary file for auto linting
  let s:neomake_makers_by_buffer = {}
  function! s:neomake_get_makers(bufnr)
    if !has_key(s:neomake_makers_by_buffer, a:bufnr)
      let s:neomake_makers_by_buffer[a:bufnr] = {}
    endif
    let l:makers_for_buffer = s:neomake_makers_by_buffer[a:bufnr]

    let l:ft = &filetype
    let l:makers = []
    let l:maker_names = neomake#GetEnabledMakers(l:ft)
    let l:tmpfile = s:neomake_temp_filename('%')
    for l:maker_name in l:maker_names
      let l:maker = neomake#GetMaker(l:maker_name, l:ft)
      let l:full_maker_name = l:ft.'_'.l:maker_name

      " Some makers (like the default go makers) operate on an entire
      " directory which breaks for this file based linting approach.
      " If 'append_file' exists and is 0 then this is a maker which
      " operates on the directory rather than the file so skip it.
      if exists('l:maker') && get(l:maker, 'append_file', 1)
        if !exists('l:makers_for_buffer[l:full_maker_name]')
          " Make sure we lint the tempfile
          let l:maker.append_file = 0
          let l:index = index(l:maker.args, '%:p')
          if l:index > -1
            let l:maker.args[l:index] = l:tmpfile
          else
            call add(l:maker.args, l:tmpfile)
          endif

          " Store off the original values
          let l:maker.obufnr = a:bufnr
          if exists('l:maker.postprocess')
            let l:maker.opostprocess = s:funcref(l:maker.postprocess)
          endif

          " Wrap the existing mapexpr to do extra processing
          " after it completes
          let l:maker.mapexpr = printf('substitute(%s, "%s", "%s", "g")',
                \ get(l:maker, 'mapexpr', 'v:val'),
                \ l:tmpfile, expand('%'))

          " Wrap the existing post process to do extra processing
          " after it completes
          function! l:maker.postprocess(entry)
            " If call the original postprocess if it exists
            if exists('l:self.opostprocess')
              call l:self.opostprocess(a:entry)
            endif

            " The neomake job was executed on the tempfile, so fix up
            " the location list entry to point to the real buffer.
            let a:entry.bufnr = l:self.obufnr

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

  function! s:neomake_setup_autolint()
    let l:bufnr = bufnr('%')
    if has_key(s:neomake_buffers, l:bufnr)
      return
    endif

    let l:makers =  s:neomake_get_makers(l:bufnr)
    if len(l:makers) > 0
      " This is a filetype with makers
      let s:neomake_buffers[l:bufnr] = {
            \ 'bufnr': l:bufnr,
            \ 'changedtick': -1,
            \ 'makers': l:makers,
            \ 'loclist': [],
            \ 'tmpfile': s:neomake_temp_filename('%'),
            \ 'timerid': -1
            \ }

      " Run neomake on the initial load of the buffer to check for errors
      call s:neomake_update(s:neomake_buffers[l:bufnr])

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Text Changed Handling
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      autocmd s:neomake TextChanged,TextChangedI <buffer>
            \ call s:neomake_onchange(bufnr('%'))
    endif
  endfunction

  function! s:neomake_onchange(bufnr, ...)
    let l:error = ''
    let l:status = ''
    let l:bufinfo = get(s:neomake_buffers, a:bufnr, {})

    let l:lasttimerid = l:bufinfo.timerid
    let l:bufinfo.timerid = -1
    if l:lasttimerid != -1
      call timer_stop(l:lasttimerid)
    endif

    let l:bufinfo.timerid = timer_start(g:neomake_autolint_updatetime,
          \ s:script_function('s:neomake_tryupdate'))
  endfunction

  function! s:neomake_tryupdate_nvim(jobid, data, event) dict
    let l:bufinfo = get(s:neomake_buffers, l:self.bufnr, {})

    " This was a canceled update
    if a:data != 0 || a:jobid != l:bufinfo.updateid
      return
    endif

    let l:bufinfo.updateid = -1
    call s:neomake_tryupdate(l:bufinfo)
  endfunction

  function! s:neomake_tryupdate(timerid)
    let l:bufinfo = {}
    for l:info in values(s:neomake_buffers)
      if l:info.timerid == a:timerid
        let l:bufinfo = l:info
        let l:bufinfo.timerid = -1
        break
      endif
    endfor

    " Could not find the buffer associated with the timer
    if empty(l:bufinfo)
      return
    endif

    call s:neomake_update(l:bufinfo)
  endfunction

  function! s:neomake_update(bufinfo, ...)
    " Need the original filetype in order to set the new buffer to the
    " correct filetype (it might not be automatically detected)
    let l:ft = &filetype

    " Write the temporary file
    call neomake#utils#DebugMessage('Autolint: Writing temporary file.')
    silent! keepalt noautocmd call writefile(getline(1, '$'), s:neomake_temp_filename('%'))

    " Run neomake in file mode with the updated makers
    " Do not run silent incase of verbose output (g:neomake_verbose)
    call neomake#Make(1, a:bufinfo.makers)
  endfunction

  function! s:neomake_remove(file)
    " Since this is called for every BufWipeout ensure it is a tracked buffer
    let l:bufnr = bufnr(a:file)
    let l:bufinfo = get(s:neomake_buffers, l:bufnr, {})

    if len(l:bufinfo) > 0
      call delete(l:bufinfo.tmpfile)
      call remove(s:neomake_buffers, l:bufnr)
    endif
  endfunction

  function! s:neomake_remove_all()
    for l:bufinfo in values(s:neomake_buffers)
      call delete(l:bufinfo.tmpfile)
    endfor
    let s:neomake_buffers = {}
  endfunction

  " Create neomake autocmd group and remove any existing neomake autocmds,
  " in case .vimrc is re-sourced.
  augroup s:neomake
    autocmd!
  augroup END

  if get(g:, 'neomake_autolint')
    " Auto commands for managing the autolinting
    autocmd s:neomake BufWinEnter * call s:neomake_setup_autolint()
    autocmd s:neomake VimLeavePre * call s:neomake_remove_all()
    autocmd s:neomake BufWipeout * call s:neomake_remove('<afile>')
  endif

  let g:airline#extensions#neomake#enabled = get(g:, 'airline_installed')
  autocmd s:neomake User NeomakeFinished,NeomakeCountsChanged nested
        \ call s:quickfix_combine()
endif

"////////////////"
" vim-commentary "
"////////////////"
if isdirectory(expand(s:plugin_directory . '/vim-commentary'))
  " example support for apache comments
  "autocmd vimrc FileType apache setlocal commentstring=#\ %s
endif

"///////////////"
" YouCompleteMe "
"///////////////"
if isdirectory(expand(s:plugin_directory . '/YouCompleteMe'))
  let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']
endif

"//////////////////////"
" vim-multiple-cursors "
"//////////////////////"
if isdirectory(expand(s:plugin_directory . '/vim-multiple-cursors'))
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
if isdirectory(expand(s:plugin_directory . '/vim-rooter'))
  " Let other plugins know vim-rooter is installed
  let g:rooter_installed = 1

  let g:rooter_use_lcd = 1
  let g:rooter_silent_chdir = 1
endif

"///////////////"
" vim-gutentags "
"///////////////"
if isdirectory(expand(s:plugin_directory . '/vim-gutentags'))
  let g:gutentags_define_advanced_commands = 1

  " Only list files that are actually part of the project
  let g:gutentags_file_list_command = {
        \ 'markers': {
        \ '.git': 'git ls-files',
        \ '.hg': 'hg files',
        \ },
        \ }

  " Update status line if airline is installed
  if get(g:, 'airline_installed')
    " Add vim-gutentags status
    function! GutentagsStatus(...)
      let w:airline_section_x = get(w:, 'airline_section_x', g:airline_section_x)
      let w:airline_section_x .= g:airline_symbols.space . '%{gutentags#statusline()}'
    endfunction
    call airline#add_statusline_func('GutentagsStatus')
  endif

  " Wrap setup in a function so variables can be local
  function s:SetupGutenTags()
    if get(g:, 'rooter_installed')
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
" undotree "
"//////////"
if isdirectory(expand(s:plugin_directory . '/undotree'))
  nnoremap <silent> <leader>u :UndotreeToggle<CR>
endif

"////////////////"
" vim-easy-align "
"////////////////"
if isdirectory(expand(s:plugin_directory . '/vim-easy-align'))
  " Start interactive EasyAlign in visual mode (e.g. vipga)
  xmap ga <Plug>(EasyAlign)

  " Start interactive EasyAlign for a motion/text object (e.g. gaip)
  nmap ga <Plug>(EasyAlign)
endif

"///////////////"
" incsearch.vim "
"///////////////"
if isdirectory(expand(s:plugin_directory . '/incsearch.vim'))
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
if isdirectory(expand(s:plugin_directory . '/incsearch-fuzzy.vim'))
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
if isdirectory(expand(s:plugin_directory . '/incsearch-easymotion.vim'))
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
if isdirectory(expand(s:plugin_directory . '/vim-easymotion'))
  nmap F <Plug>(easymotion-s)
endif

"////////////"
" indentLine "
"////////////"
if isdirectory(expand(s:plugin_directory . '/indentLine'))
  let g:indentLine_fileTypeExclude=['text', 'help']
endif
