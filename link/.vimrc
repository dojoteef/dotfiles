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
  let g:macos = s:uname =~? 'darwin'
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

" File Explorer
if executable('fzf')
  Plug '~/.fzf' | Plug 'junegunn/fzf.vim'
endif

" Latex support
if executable('latexmk') || executable('latexrun')
  Plug 'lervag/vimtex'
endif

" tmux
Plug 'tmux-plugins/vim-tmux'

" Misc
Plug 'google/vim-jsonnet'
Plug 'rickhowe/diffchar.vim'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

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
set showmode " Show mode by default
set laststatus=2 " Always show status line
set colorcolumn=+1 " Make it obvious where text would wrap with 'textwidth'
set background=dark
colorscheme desert
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
" USER INTERFACE {{{1
""""""""""""""""""""""""
set splitright " New split goes to the right
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
" FORMATTING {{{1
""""""""""""""""""""""""
set shiftwidth=2 " The # of spaces for indenting.
set softtabstop=2 " Tab key results in 2 spaces
set tabstop=2 " Tabs indent only 2 spaces
set expandtab " Expand tabs to spaces
set nojoinspaces " Only insert single space after a '.', '?' and '!' with a join command.
set hlsearch " Highlight searches

" Set wrapping by default in tex files
autocmd vimrc FileType tex set wrap

" Use json indenting for jsonnet; it's close enough, and there doesn't seem to
" be a dedicated indenter for jsonnet.
autocmd vimrc FileType jsonnet set indentexpr=GetJSONIndent()

""""""""""""""""""""""""
" KEYMAPPINGS {{{1
""""""""""""""""""""""""
" Change mapleader
let g:mapleader=','
let g:maplocalleader='\'

" Toggle paste
noremap <silent> <leader>pp :set invpaste paste?<CR>

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
" FUNCTION: s:script_function() {{{2
function! s:script_function(func) abort
  " See http://stackoverflow.com/a/17184285
  return substitute(a:func, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_'),'')
endfunction

" FUNCTION: s:determine_slash() {{{2
function! s:determine_slash() abort
  let s:slash = &shellslash || !exists('+shellslash') ? '/' : '\'
endfunction
call s:determine_slash()

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

  if s:PlugActive('vim-airline')
    " The sections 'c' & 'x' use the 'NonText' highlight which is hard to read
    " so instead use the 'Directory' highlight.
    function! s:AirlineZenburnPatch(palette)
      if g:airline_theme ==# 'zenburn'
        for l:mode in ['normal', 'inactive']
          for l:section in ['c', 'x']
            let a:palette[l:mode]['airline_'.l:section] =
                  \ airline#themes#get_highlight('Directory')
          endfor
        endfor
      endif
    endfunction

    let g:airline_theme_patch_func = s:script_function('s:AirlineZenburnPatch')
  endif
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
  set runtimepath+=/usr/local/opt/fzf
endif

"/////////"
" Airline {{{2
"/////////"
if s:PlugActive('vim-airline')
  " Don't show the current mode; airline takes care of it
  set noshowmode

  " See https://github.com/vim-airline/vim-airline/issues/1125
  let g:airline_exclude_preview = 1

  " Use the same theme as the currently selected colorscheme
  let g:airline_theme = g:colors_name

  " Enabled extensions
  let g:airline_extensions = ['tabline']
  let g:airline#extensions#disable_rtp_load = 1

  " Setup powerline fonts and symbols {{{3
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

  " Setup default extension {{{3
  let g:airline#extensions#default#section_truncate_width = {
        \ 'b': 60,
        \ 'x': 45,
        \ 'y': 60,
        \ 'z': 30,
        \ 'warning': 60,
        \ 'error': 60,
        \ }

  " Define custom parts which are more compact than the default {{{3
  let s:part = []
  call add(s:part, '%{g:airline_symbols.linenr}')
  call add(s:part, '%{g:airline_symbols.space}')
  call add(s:part, '%#__accent_bold#%l%#__restore__#')
  call airline#parts#define('linenr', {
        \ 'raw': join(s:part, ''),
        \ 'accent': 'bold'})

  let s:part = []
  call add(s:part, '%#__accent_bold#')
  call add(s:part, '/%L%{g:airline_symbols.maxlinenr}')
  call add(s:part, '%#__restore__#')
  call airline#parts#define('maxlinenr', {
        \ 'raw': join(s:part, ''),
        \ 'accent': 'bold'})

  function! s:AirlinePath(...)
    let l:winwidth = a:0 ? a:1 : winwidth(0)

    let l:path = bufname(a:0 ? a:2 : '%')
    let l:finalpath = l:path
    for l:count in ['', '9', '8', '7', '6', '5', '4', '3', '2', '1']
      let l:convertbacklash = ':gs?\\?/?'
      let l:shorten = printf(':gs?\%%(\([^/]\{1,%s}\)[^/]*\)*?\1?', l:count)
      let l:pattern = printf(':~:.:h%s%s', l:convertbacklash, l:shorten)
      let l:finalpath = join([fnamemodify(l:path, l:pattern), fnamemodify(l:path, ':t')], '/')
      if l:winwidth - strlen(l:finalpath) > 40
        break
      endif
    endfor
    return l:finalpath
  endfunction
  call airline#parts#define('file', {
        \ 'function': s:script_function('s:AirlinePath'),
        \ })
  call airline#parts#define('path', {
        \ 'function': s:script_function('s:AirlinePath'),
        \ })

  " Custom mode names for truncation
  let s:airline_short_mode_map = {
        \ 'n'  : 'N',
        \ 'i'  : 'I',
        \ 'R'  : 'R',
        \ 'v'  : 'V',
        \ 'V'  : 'VL',
        \ 'c'  : 'C',
        \ '' : 'VB',
        \ 's'  : 'S',
        \ 'S'  : 'SL',
        \ '' : 'SB',
        \ 't'  : 'T',
        \ }

  function! s:AirlineMode()
    let l:pathlen = strlen(s:AirlinePath())
    let l:mode = get(w:, 'airline_current_mode', '')
    return winwidth(0) - l:pathlen < 79 ? s:airline_short_mode_map[mode()] : l:mode
  endfunction

  call airline#parts#define('mode', {
        \ 'function': s:script_function('s:AirlineMode'),
        \ 'accent': 'bold',
        \ })

  " Custom sections for better truncation {{{3
  function! s:AirlineSectionB(builder, context, ...)
    let s:airline_section_b_short = get(s:,
          \ 'airline_section_b_short',
          \ airline#section#create(['branch']))

    let l:winwidth = winwidth(a:context.winnr)
    let l:pathlen = strlen(s:AirlinePath(l:winwidth, a:context.bufnr))
    if l:winwidth - l:pathlen < 60
      let w:airline_section_b = s:airline_section_b_short
    endif
  endfunction
  call airline#add_statusline_func(s:script_function('s:AirlineSectionB'))

  let g:airline_section_z = airline#section#create([
        \ '%p%%', 'linenr', 'maxlinenr', g:airline_symbols.space.'%2v'])

  function! s:AirlineSectionZ(builder, context, ...)
    let s:airline_section_z_short = get(s:,
          \ 'airline_section_z_short',
          \ airline#section#create(['%l:%2v']))

    let l:winwidth = winwidth(a:context.winnr)
    let l:pathlen = strlen(s:AirlinePath(l:winwidth, a:context.bufnr))
    if l:winwidth - l:pathlen < 50
      let w:airline_section_z = s:airline_section_z_short
    endif
  endfunction
  call airline#add_statusline_func(s:script_function('s:AirlineSectionZ'))

  " Setup tabline extension {{{3
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#fnamemod = ':.:t'
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let g:airline#extensions#tabline#ignore_bufadd_pat = '\c\vnerd_tree'
endif

"////////////"
" promptline {{{2
"////////////"
if g:vim_installing && s:PlugActive('promptline.vim')
  " Add to the list of enabled extensions
  let g:airline_extensions += ['promptline']

  " promptline (needs to be after the plugins are activated since it uses a
  " function from promptline which hasn't been sourced yet...)
  let g:promptline_theme = 'airline'
  let g:promptline_powerline_symbols = g:airline_powerline_fonts
  let g:promptline_preset = {
        \ 'a' : [ promptline#slices#host({'only_if_ssh': 1}), promptline#slices#user() ],
        \ 'b' : [ promptline#slices#cwd() ],
        \ 'c' : [ promptline#slices#vcs_branch(), promptline#slices#git_status() ],
        \ 'warn' : [ promptline#slices#last_exit_code() ]
        \}
endif

"////////////"
" tmuxline {{{2
"////////////"
if g:vim_installing && s:PlugActive('tmuxline.vim')
  " Add to the list of enabled extensions
  let g:airline_extensions += ['tmuxline']

  " tmuxline
  let g:tmuxline_theme = 'airline'
  let g:tmuxline_powerline_separators = g:airline_powerline_fonts
endif

"//////////"
" vimtex {{{2
"//////////"
if s:PlugActive('vimtex')
  let g:tex_flavor = 'latex'
  let g:vimtex_quickfix_mode = 2
  let g:vimtex_quickfix_open_on_warning = 0

  if executable('skimpdf')
    let g:vimtex_view_method = 'skim'
  endif

  if executable('nvr')
    let g:vimtex_compiler_progname = 'nvr'
  endif

  let g:vimtex_compiler_latexmk = {
      \ 'background' : 1,
      \ 'build_dir' : '.latex',
      \ 'callback' : 1,
      \ 'continuous' : 1,
      \ 'executable' : 'latexmk',
      \ 'options' : [
      \   '-pdf',
      \   '-verbose',
      \   '-file-line-error',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \ ],
      \}
endif

"//////////////"
" vim-devicons {{{2
"//////////////"
if s:PlugActive('vim-devicons')
  let g:webdevicons_enable_airline_statusline = 0
  let g:webdevicons_enable_airline_statusline_fileformat_symbols = 0

  if s:PlugActive('vim-airline')
    " Custom sections for better truncation
    function! s:AirlineDevIcons(builder, context, ...)
      let l:section = []
      let l:winwidth = winwidth(a:context.winnr)
      let l:pathlen = strlen(s:AirlinePath(l:winwidth, a:context.bufnr))
      if l:winwidth - l:pathlen > 60
        call add(l:section, get(w:, 'airline_section_x', g:airline_section_x))
      endif

      call add(l:section, '%{WebDevIconsGetFileTypeSymbol()}')
      let w:airline_section_x = join(l:section, g:airline_symbols.space)

      let l:section = []
      let l:space = '.g:airline_symbols.space.'
      if l:winwidth - l:pathlen > 79
        call add(l:section, '&fenc')
      endif

      call add(l:section, 'WebDevIconsGetFileFormatSymbol()')
      let w:airline_section_y = printf('%%{%s}', join(l:section, l:space))
    endfunction

    call airline#add_statusline_func(s:script_function('s:AirlineDevIcons'))
  endif
endif

" vim: set sw=2 sts=2 fdm=marker:
