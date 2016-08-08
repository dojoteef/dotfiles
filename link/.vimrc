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

" Syntax
Plug 'mhinz/vim-signify'
Plug 'neomake/neomake'
Plug 'sheerun/vim-polyglot'

" Formatting
if executable('go')
  Plug 'fatih/vim-go'
endif
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Valloric/YouCompleteMe', { 'do': b:ycm_install_cmd }

" File Explorer
if executable('fzf')
  Plug '~/.fzf' | Plug 'junegunn/fzf.vim'
endif
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle'] }
      \ | Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTree', 'NERDTreeToggle'] }

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

""""""""""""""""""""""""
" GENERAL
""""""""""""""""""""""""
" Local dirs
set backupdir=$DOTFILES/caches/vim
set directory=$DOTFILES/caches/vim
set undodir=$DOTFILES/caches/vim

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
colorscheme zenburn
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
set nosplitbelow " New split goes top
set splitright " New split goes right
set hidden " When a buffer is brought to foreground, remember undo history and marks.
set report=0 " Show all changes.
set mouse=a " Enable mouse in all modes.
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

" Clear search highlight
nnoremap <silent> <leader>/ :nohlsearch<CR>

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

""""""""""""""""""""""""
" FILE TYPES
""""""""""""""""""""""""
autocmd vimrc BufRead .vimrc,*.vim set keywordprg=:help
autocmd vimrc BufRead,BufNewFile *.md set filetype=markdown
autocmd vimrc BufRead,BufNewFile *.tmpl set filetype=html

" Ignore things
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*

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
    let l:varname = 'w:neomake_loclist_'.var
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
  noremap <leader>k :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

  " New command :Ag which takes standard ag arguments
  command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
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
  " See https://github.com/vim-airline/vim-airline/issues/1125
  let g:airline_exclude_preview = 1

  let g:airline_theme = 'zenburn'
  let g:airline#extensions#tmuxline#enabled = g:vim_installing
  let g:airline#extensions#promptline#enabled = g:vim_installing
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#fnamemod = ':.:t'
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let airline#extensions#tabline#ignore_bufadd_pat = '\c\vnerd_tree'

  " Only enable powerline fonts in iTerm when using the Powerline profile
  let g:airline_powerline_fonts = 1
  " I think I'm happy enough with my tweak to the fonts in Terminal to use
  " Powerline fonts for both Terminal and iTerm
  "      \ $TERM_PROGRAM == "iTerm.app"
  "      \ && $ITERM_PROFILE == "Powerline"

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
  map <leader>n :NERDTreeToggle<CR>
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
  let g:neomake_updatetime = 2000
  let g:neomake_list_height = 10
  let g:neomake_max_location_lists = 1

  " For debugging
  " let g:neomake_verbose = 3

  let s:neomake_buffers = {}
  function! Neomake_buffer_name(basename)
    let l:fname = expand(a:basename.':p:t')
    let l:tmpdir = fnamemodify(tempname(), ':p:h')
    return fnameescape(join([l:tmpdir, l:fname], '/'))
  endfunction

  let s:neomake_makers_by_buffer = {}
  function! Neomake_get_makers(bufnr)
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
          endfunction

          let l:maker.name = l:full_maker_name
          let l:makers_for_buffer[l:full_maker_name] = l:maker
        endif

        call add(l:makers, l:maker)
      endif
    endfor

    return l:makers
  endfunction

  " The reason the location list management is setup the way it is has to do
  " with the difficulty of window management with (neo)vim. Once that issue is
  " addressed this can be revisited:
  " https://github.com/neovim/neovim/issues/3933
  " http://tarruda.github.io/articles/neovim-smart-ui-protocol/
  function! Neomake_manage_loclists(bufnr, ...)
    if !has_key(s:neomake_buffers, a:bufnr)
      call neomake#utils#DebugMessage("IDE: not a recognized neomake buffer")
      return
    endif

    if exists('s:neomake_managing_loclists')
      call neomake#utils#DebugMessage("IDE: already managing location lists")
      return
    endif

    let w:neomake_loclist_winnr = 1
    if a:0
      " Use the passed in location list if specified
      let l:loclist = a:1
    else
      " Otherwise find the first location list associated with the specified
      " buffer
      let l:loclist = []
      let l:tabwinnr = s:bufallwinnr(a:bufnr, tabpagenr())
      for [tabnr, winnr] in l:tabwinnr
        let l:loclist = getloclist(winnr)
        if len(l:loclist) > 0
          call neomake#utils#DebugMessage("IDE: found non-empty location list in window ".winnr)
          break
        endif
      endfor
    endif

    let s:neomake_managing_loclists = 1
    call Neomake_windo('Neomake_loclist_set', a:bufnr, l:loclist)
    call s:repeat_while_true('Neomake_windo', 'Neomake_loclist_close')
    call s:repeat_while_true('Neomake_windo', 'Neomake_loclist_open')
    let l:winnr =  Neomake_windo('s:find_window', 'w:neomake_loclist_winnr')
    call Neomake_windo('s:unlet', 'w:neomake_loclist_', ['opened', 'closed', 'winnr'])
    unlet s:neomake_managing_loclists

    if l:winnr != v:null
      call neomake#utils#DebugMessage("IDE: switching to window: ".l:winnr)
      execute string(l:winnr).'wincmd w'
    endif
  endfunction

  function! Neomake_windo(...)
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

  function! Neomake_loclist_set(...)
    let l:bufnr = get(a:, '1')
    let l:loclist = get(a:, '2', [])
    if l:bufnr == bufnr('%')
      call neomake#utils#DebugMessage("IDE: setting location list for bufnr: ".l:bufnr." winnr: ".winnr())
      call setloclist(0, l:loclist, 'r')
    endif
  endfunction

  function! Neomake_loclist_close(...)
    let l:empty_only = get(a:, '1')
    if !exists('w:neomake_loclist_closed')
          \ && (!l:empty_only || len(getloclist(0)) == 0)
      call neomake#utils#DebugMessage("IDE: closing the location list for bufnr: ".bufnr('%')." winnr: ".winnr())
      let w:neomake_loclist_closed = 1

      lclose
      return 1
    endif
  endfunction

  function! Neomake_loclist_open(...)
    if len(getloclist(0)) > 0 && !exists('w:neomake_loclist_opened')
      call neomake#utils#DebugMessage("IDE: opening the location list for bufnr: ".bufnr('%')." winnr: ".winnr())
      let w:neomake_loclist_opened = 1

      "execute 'lopen' g:neomake_list_height
      lopen
      return 1
    endif
  endfunction

  function! Neomake_loclist_setup(bufnr)
    if exists('w:neomake_loclist_setup') || !has_key(s:neomake_buffers, a:bufnr)
      return
    endif

    let w:neomake_loclist_setup = 1
    call Neomake_manage_loclists(a:bufnr)
  endfunction

  function! Neomake_setup_ide()
    let l:bufnr = bufnr('%')
    if has_key(s:neomake_buffers, l:bufnr)
      " Make sure the location list is opened or closed as necessary
      call Neomake_manage_loclists(l:bufnr)
      return
    endif

    let l:makers =  Neomake_get_makers(l:bufnr)
    if len(l:makers)
      " This is a filetype with makers
      let s:neomake_buffers[l:bufnr] = {
            \ 'bufnr': l:bufnr,
            \ 'file': Neomake_buffer_name('%'),
            \ 'force': 0,
            \ 'job_ids': [],
            \ 'makers': l:makers
            \ }

      " Make sure the sign column is always showing
      execute 'sign place 999999 line=1 name=neomake_invisible buffer='.l:bufnr

      " Run neomake on the initial load of the buffer to check for errors
      let b:lastchangedtick = -1
      call Neomake_onchange(l:bufnr)

      autocmd s:neomake BufWinLeave <buffer>
            \ silent! call Neomake_manage_loclists(expand('<abuf>'))

      autocmd s:neomake WinEnter <buffer>
            \ silent! call Neomake_loclist_setup(expand('<abuf>'))

      autocmd s:neomake TextChangedI,CursorHoldI <buffer>
            \ silent! call Neomake_onchange(bufnr('%'))

      autocmd s:neomake TextChanged,InsertLeave,CursorHold <buffer>
            \ silent! call Neomake_onchange(bufnr('%'), 1)
    endif
  endfunction

  function! Neomake_running(bufinfo)
    " Check for manually initiated jobs
    let l:jobs = neomake#GetJobs()
    for jobinfo in values(l:jobs)
      if jobinfo.bufnr == a:bufinfo.bufnr
        return 1
      endif
    endfor

    return 0
  endfunction

  function! Neomake_onchange(bufnr, ...)
    " Only run if the buffer has been modified
    if b:changedtick == b:lastchangedtick
      return
    endif

    " Get the appropriate buffer info by filename
    let l:bufinfo = s:neomake_buffers[a:bufnr]

    " See if a force update is specified. If there is an external
    " (not initiated by the IDE) job pending it will run after the
    " current job completes.
    let l:bufinfo.force = l:bufinfo.force || get(a:, '1')

    " Only run neomake if there isn't already a job running for this buffer.
    if Neomake_running(l:bufinfo)
      return
    endif

    " Get current time and elasped time since last update
    let l:time = reltime()
    if has_key(l:bufinfo, 'updated')
      let l:updated = l:bufinfo.updated
      let l:elapsed = 1000 * str2float(reltimestr(reltime(l:updated, l:time)))
    else
      let l:elapsed = g:neomake_updatetime
    endif

    " If enough time has passed since the last update or forcing an update.
    if !l:bufinfo.force && l:elapsed < g:neomake_updatetime
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
    let b:lastchangedtick = b:changedtick
    let l:bufinfo.updated = l:time

    " Need the original filetype in order to set the new buffer to the
    " correct filetype (it might not be automatically detected)
    let l:ft = &filetype

    " Store off current state
    let l:winstate = winsaveview()

    " Remove all signs on the current buffer
    call neomake#signs#ResetFile(a:bufnr)

    " Write the temporary file and open it
    let l:tmpfile = l:bufinfo.file
    silent! call writefile(getline(1, '$'), l:tmpfile)
    silent! execute 'edit' l:tmpfile

    " Make sure it is unlisted and has the proper filetype
    silent! execute 'setlocal bufhidden=hide noswapfile nobuflisted filetype='.l:ft

    " Run neomake in file mode with the updated makers
    " Do not run silent incase of verbose output (g:neomake_verbose)
    let l:bufinfo.job_ids = neomake#Make(1,
          \ l:bufinfo.makers, function('Neomake_job_completed'))

    " Edit the previous buffer (the original file)
    silent! execute 'edit' fnameescape(expand('#'))

    " Restore winstate and redraw
    silent! call winrestview(l:winstate)
  endfunction

  function! Neomake_job_completed(info)
    " There are more jobs for this maker so wait for them to complete.
    if a:info.has_next
      return
    endif

   " The maker name includes the bufnr, so coerce the string into
   " a number ("1_string" + 0 == 1)
   let s:neomake_completed_bufnr = a:info.name + 0
  endfunction

  function! Neomake_complete()
    " This completion is not from the IDE
    if !exists('s:neomake_completed_bufnr')
      return
    endif

    " Get the original bufinfo
    let l:bufnr = s:neomake_completed_bufnr
    let l:bufinfo = s:neomake_buffers[l:bufnr]
    unlet s:neomake_completed_bufnr

    " Clear out the list of job ids since they have all finished
    let l:bufinfo.job_ids = []
    silent! call neomake#CleanOldFileSignsAndErrors(l:bufnr)

    " Make sure the location list is opened or closed as necessary
    call Neomake_manage_loclists(l:bufnr, getloclist(0))

    let l:bufinfo = s:neomake_buffers[l:bufnr]
    if l:bufinfo.force
      " If there is a force update pending then go ahead and trigger it
      call Neomake_onchange(l:bufnr, l:bufinfo.force)
    endif
  endfunction

  function! Neomake_remove(file)
    " Since this is called for every BufWipeout ensure it is a tracked buffer
    let l:bufnr = bufnr(a:file)
    let l:bufinfo = get(s:neomake_buffers, l:bufnr, {})

    if len(l:bufinfo)
      call delete(l:bufinfo.file)
      call remove(s:neomake_buffers, l:bufnr)
    endif
  endfunction

  function! Neomake_remove_all()
    for bufinfo in keys(s:neomake_buffers)
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
    autocmd s:neomake BufWinEnter * call Neomake_setup_ide()
    autocmd s:neomake User NeomakeFinished nested call Neomake_complete()
    autocmd s:neomake VimLeavePre * call Neomake_remove_all()
    autocmd s:neomake BufWipeout * call Neomake_remove('<afile>')
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
