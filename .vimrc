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
" Session management
NeoBundle 'xolox/vim-misc'
NeoBundle 'xolox/vim-session'
" Highlight cursor word
NeoBundle 'ihacklog/HiCursorWords'
" Highlight trailing whitespaces
NeoBundle 'bronson/vim-trailing-whitespace'
" Code comments
NeoBundle 'tomtom/tcomment_vim'
" Display Marks in the left margin
NeoBundle 'kshenoy/vim-signature'
" Diff blocks instead of full files
NeoBundle 'AndrewRadev/linediff.vim'
" Indent guides
NeoBundle 'nathanaelkane/vim-indent-guides'
" Autocompletion
if (has('python')) && (v:version > 703 || (v:version == 703 && has('patch584')))
    let g:neobundle#install_process_timeout = 1800 "YouCompleteMe is slow to get
    NeoBundle 'Valloric/YouCompleteMe', {
                \ 'build' : {
                \   'unix' : './install.sh'
                \ },
                \ }
endif

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
" 256-colors support
set t_Co=256

" Sets how many lines of history VIM has to remember
set history=1000
set undolevels=1000

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

" Don't go to SELECT mode instead of VISUAL mode
:behave xterm

" From http://vim.wikia.com/wiki/Search_for_visually_selected_text
" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy/<C-R><C-R>=substitute(
    \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy?<C-R><C-R>=substitute(
    \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>

" In visual mode, replace selected text
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" In visual mode, search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy/<C-R><C-R>=substitute(
    \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy?<C-R><C-R>=substitute(
    \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set scrolloff=7

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hidden

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,[,],h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Stop highlighting search results by pressing CR in normal mode
nnoremap <cr> :noh<CR><CR>:<backspace>

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set matchtime=2

set noerrorbells
set novisualbell
set t_vb=

" Time in ms for key code sequences
set timeoutlen=500 ttimeoutlen=10

" Show line numbers
set number
" show command in bottom bar
set showcmd
" highlight current line
set cursorline

" Default split behaviour
set splitbelow
set splitright

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => File types
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.ad set filetype=asciidoc
autocmd BufNewFile,BufRead *.adoc set filetype=asciidoc
autocmd BufNewFile,BufRead *.asciidoc set filetype=asciidoc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" set background=dark " Can help other plugins find correct colors
colorscheme badwolf

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set fileformats=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowritebackup
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" No automatic linebreak
set nolinebreak
set textwidth=0

set autoindent
set wrap " Wrap lines for display

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-airline plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline_theme = 'light'
let g:airline_powerline_fonts=0
" Always display status bar
set laststatus=2
" Use nicer symbols in the bars
set guifont=PowerlineSymbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
" unicode symbols
let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_symbols.paste = '▽'
let g:airline_symbols.readonly = '❎'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.modified = '⚑'
let g:airline_symbols.space = ' '


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => tagbar plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <F8> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_show_linenumbers = 1

let g:tagbar_type_asciidoc = {
    \ 'ctagstype' : 'asciidoc',
    \ 'kinds' : [
        \ 'h:table of contents',
        \ 'a:anchors:1',
        \ 't:titles:1',
        \ 'n:includes:1',
        \ 'i:images:1',
        \ 'I:inline images:1'
    \ ],
    \ 'sort' : 0
    \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => bufexplorer plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:_sq_buffers_startup_reloaded = 0
function _sq_bufexplorer_shortcut()
    " Display the bufexplorer windows, but reloads all buffers at first attempt.
    "  Useful because bufexplorer doesn't know about buffers at startup when
    "  a session was restored via vim-restored, and doesn't display much in that
    "  case...
    if g:_sq_buffers_startup_reloaded == 0
        let g:_sq_buffers_startup_reloaded = 1
        if exists('g:session_default_name') " only needed if vim-session is used
            :bfirst
            let l:current = 1
            let l:last = bufnr("$")
            while l:current <= l:last
                if bufexists(l:current)
                    execute ":buffer ".l:current
                endif
                let l:current = l:current + 1
            endwhile
        endif
    endif
    :BufExplorer
endfunction

nmap <F9> :call _sq_bufexplorer_shortcut()<CR>
let g:bufExplorerReverseSort=0
let g:bufExplorerShowDirectories=1
let g:bufExplorerShowNoName=1
let g:bufExplorerShowRelativePath=0
let g:bufExplorerShowTabBuffer=1
let g:bufExplorerShowUnlisted=1
let g:bufExplorerSortBy='fullpath'
let g:bufExplorerSplitOutPathName=1


" Enable syntax highlighting when buffers are displayed in a window through
" :argdo and :bufdo, which disable the Syntax autocmd event to speed up
" processing.
" from https://stackoverflow.com/questions/12485981/syntax-highlighting-is-not-turned-on-in-vim-when-opening-multiple-files-using-ar
augroup EnableSyntaxHighlighting
    autocmd! BufWinEnter,WinEnter * nested if exists('syntax_on') && ! exists('b:current_syntax') && ! empty(&l:filetype) && index(split(&eventignore, ','), 'Syntax') == -1 | syntax enable | endif
    autocmd! BufRead * if exists('syntax_on') && exists('b:current_syntax') && ! empty(&l:filetype) && index(split(&eventignore, ','), 'Syntax') != -1 | unlet! b:current_syntax | endif
augroup END


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
" => vim-session plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:let g:session_autoload = 'yes'
:let g:session_autosave = 'yes'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HiCursorWords plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Don't hilight unless the cursor doesn't move for 1 second
let g:HiCursorWords_delay = 1000

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-indent-guides plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 4
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
" set indent colors: very light (not visible AT ALL on gvim though...)
hi IndentGuidesOdd  ctermbg=233
hi IndentGuidesEven ctermbg=234
let g:indent_guides_color_change_percent=100

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim-signature plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" From https://gist.github.com/kshenoy/14f2c4ce7af28b54882b
" This function returns the highlight group used by git-gutter depending on how the line was edited (added/modified/deleted)
function! SignatureGitGutter(lnum)
    let gg_line_state = filter(copy(gitgutter#diff#process_hunks(gitgutter#hunk#hunks())), 'v:val[0] == a:lnum')

    if len(gg_line_state) == 0
        return 'Exception'
    endif

    if gg_line_state[0][1] =~ 'added'
        return 'GitGutterAdd'
    elseif gg_line_state[0][1] =~ 'modified'
        return 'GitGutterChange'
    elseif gg_line_state[0][1] =~ 'removed'
        return 'GitGutterDelete'
    endif
endfunction

" Next, assign it to g:SignatureMarkTextHL
let g:SignatureMarkTextHL = 'SignatureGitGutter(a:lnum)'

" Now everytime Signature wants to place a sign, it calls this function and thus, we can dynamically assign a Highlight group g:SignatureMarkTextHL
" The advantage of doing it this way is that this decouples Signature from git-gutter. Both can remain unaware of the other.

" Plugin tuning
let g:SignaturePurgeConfirmation = 1 " avoid loosing all marks on m<space>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Use local .vimrc
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

