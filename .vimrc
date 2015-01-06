"NeoBundle Scripts-----------------------------

" Install NeoBundle if not present yet
if !isdirectory(expand('~')."/.vim/bundle/neobundle.vim")
    !wget https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh --quiet -O - | /bin/bash
endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
"NeoBundle 'Shougo/neosnippet.vim'
"NeoBundle 'Shougo/neosnippet-snippets'
"NeoBundle 'ctrlpvim/ctrlp.vim'
"NeoBundle 'flazz/vim-colorschemes'

" You can specify revision/branch/tag.
"NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Title and Status bar tuning
NeoBundle 'bling/vim-airline'
" Tag bar (quickly view the classes/functions/vars in a file, and jump there)
NeoBundle 'majutsushi/tagbar'
" Show VCS diffs while editing (changes/removed/added lines), and stage/revert hunks
NeoBundle 'airblade/vim-gitgutter'
" Git wrapper, for integration with vim-airline (branch and commits in statusbar)
NeoBundle 'tpope/vim-fugitive'
" Quickly view open buffers and switch between them
NeoBundle 'jlanzarotta/bufexplorer'
" Dark color scheme
NeoBundle 'sjl/badwolf'
" Python-specific tools
NeoBundle 'klen/python-mode'

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------


" Mostly from http://amix.dk/vim/vimrc.html

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let g:mapleader = ","

" Add 'jk' combination to exit insert mode
:inoremap jk <esc>

" Force checking for modifications from the outside world
:au CursorHold * if getcmdtype() == '' | checktime | endif

" Hilight columns > 80 chars
set colorcolumn=80

" Automatically change window's cwd to file's dir
set autochdir

" Disable folding when opening files
set foldlevel=99
set foldlevelstart=99

" Disable folding (slows things down a lot sometimes)
set foldmethod=manual

" Always set curdir to current file
set autochdir

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,[,],h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Show line numbers
set number
" show command in bottom bar
set showcmd
" highlight current line
set cursorline

" Default split behaviour
set splitbelow
set splitright
" Always display status bar
set laststatus=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

colorscheme badwolf
" set background=dark

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-airline plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_theme = 'light'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => tagbar plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <F8> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => bufexplorer plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <F9> <leader>be
let g:bufExplorerReverseSort=0
let g:bufExplorerShowDirectories=1
let g:bufExplorerShowNoName=1
let g:bufExplorerShowRelativePath=0
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerShowUnlisted=1
let g:bufExplorerSortBy='fullpath'
let g:bufExplorerSplitOutPathName=1



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-signify plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

highlight DiffAdd           cterm=bold ctermbg=none ctermfg=119
highlight DiffDelete        cterm=bold ctermbg=none ctermfg=167
highlight DiffChange        cterm=bold ctermbg=none ctermfg=227

" highlight signs in Sy

highlight SignifySignAdd    cterm=bold ctermbg=none  ctermfg=119
highlight SignifySignDelete cterm=bold ctermbg=none  ctermfg=167
highlight SignifySignChange cterm=bold ctermbg=none  ctermfg=227


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => python-mode plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Disable python-mode rope autocompletion on dot since it makes things VERY slow
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_lookup_project = 0
let g:pymode_rope_autoimport = 0
let g:pymode_rope_autoimport_import_after_complete = 0
" Disable auto pylint check when writing a python file
let g:pymode_lint_write = 0
" Interferes with autocomplete feature...
let g:pymode_lint = 0
