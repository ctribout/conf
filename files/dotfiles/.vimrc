"NeoBundle Scripts-----------------------------

" Required:
filetype plugin indent on
if has('vim_starting')
    if &compatible
        set nocompatible               " Be iMproved
    endif
endif

let _sq_uid = system('id -u')
if (_sq_uid != 0)
    " Install NeoBundle if not present yet
    if !isdirectory(expand('~')."/.vim/bundle/neobundle.vim")
        echom "Please install neobundle first. Use install.sh script."
        exit 1
    endif

    if has('vim_starting')
        " Required:
        set runtimepath+=~/.vim/bundle/neobundle.vim/
    endif

    " Required:
    call neobundle#begin(expand('~/.vim/bundle'))

    " Let NeoBundle manage NeoBundle
    " Required:
    NeoBundleFetch 'Shougo/neobundle.vim'

    " Dark color scheme
    NeoBundle 'sjl/badwolf'
    NeoBundle 'nanotech/jellybeans.vim'
    " Title and Status bar tuning
    NeoBundle 'vim-airline/vim-airline'
    NeoBundle 'vim-airline/vim-airline-themes'
    " Highlight cursor word
    NeoBundle 'reidHoruff/HiCursorWords'
    " Highlight trailing whitespaces
    NeoBundle 'bronson/vim-trailing-whitespace'
    " Navigate through indent levels
    NeoBundle 'kamou/vim-indentwise'
    " Display Marks in the left margin
    NeoBundle 'kshenoy/vim-signature'
    if !&diff
        " Tag bar (quickly view the classes/functions/vars in a file, and jump there)
        NeoBundle 'majutsushi/tagbar'
        " Show git diffs while editing (changes/removed/added lines)
        " NeoBundle 'mhinz/vim-signify'
        NeoBundle 'airblade/vim-gitgutter'
        " Git wrapper, for integration with vim-airline (branch and commits in statusbar)
        NeoBundle 'tpope/vim-fugitive'
        " Quickly view open buffers and switch between them
        NeoBundle 'jlanzarotta/bufexplorer'
        " Session management
        NeoBundle 'xolox/vim-misc'
        NeoBundle 'xolox/vim-session'
        " Code comments
        NeoBundle 'tomtom/tcomment_vim'
        " Diff blocks instead of full files
        NeoBundle 'AndrewRadev/linediff.vim'
        " Indent guides
        NeoBundle 'nathanaelkane/vim-indent-guides'
        " Toggle words
        NeoBundle 'vim-scripts/toggle_words.vim'
        " jinja2 syntax
        NeoBundle 'Glench/Vim-Jinja2-Syntax'
        " Utilities for tabs
        NeoBundle 'gcmt/taboo.vim'
        " Syntax check
        NeoBundle 'dense-analysis/ale'
        " Switch between header and implementation files
        NeoBundle 'derekwyatt/vim-fswitch'
        " Rust support
        NeoBundle 'rust-lang/rust.vim'
        " Markdown support
        NeoBundle 'vim-pandoc/vim-pandoc-syntax'
        " Grep utilities
        NeoBundle 'yegappan/grep'
        " The NERD tree allows you to explore your filesystem and to open files and
        " directories
        NeoBundle 'scrooloose/nerdtree'
        " Man
        NeoBundle 'jez/vim-superman'
        " CMake syntax color
        NeoBundle 'pboettch/vim-cmake-syntax'

        " Autocompletion
        if (has('python') || has('python3')) && (v:version > 703 || (v:version == 703 && has('patch584')))
            let g:neobundle#install_process_timeout = 1800 "YouCompleteMe is slow to get
            " add '--clang-completer --rust-completer' if need be
            if has('patch-8.1.2269')
                NeoBundle 'Valloric/YouCompleteMe', {
                            \ 'build' : { 'unix' : './install.py' },
                            \ }
            else
                NeoBundle 'Valloric/YouCompleteMe', {
                            \ 'build' : { 'unix' : 'git submodule update --init --recursive && python3 ./install.py' }, 'rev': 'd98f896ada495c3687007313374b2f945a2f2fb4',
                            \ }
            endif
        endif
    endif

    " Required:
    call neobundle#end()

    " If there are uninstalled bundles found on startup,
    " this will conveniently prompt you to install them.
    NeoBundleCheck
    "End NeoBundle Scripts-------------------------
endif

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

" Disable modeline feature, not useful and possibly a security risk
set modelines=0
set nomodeline

" " Default copy buffer is the system clipboard
" set clipboard=unnamed
" if has('unnamedplus')
"     set clipboard=unnamedplus
" endif

" Add 'jk' combination to exit insert mode
:inoremap jk <esc>

" Force checking for modifications from the outside world
:au CursorHold * if getcmdtype() == '' | checktime | endif

" Hilight columns > 88 chars
if exists("&colorcolumn")
    set colorcolumn=88
endif

" Automatically change window's cwd to file's dir
autocmd BufEnter * silent! lcd %:p:h
" set autochdir

" Disable folding when opening files
set foldlevel=99
set foldlevelstart=99

" Disable folding (slows things down a lot sometimes)
set foldmethod=manual

" To be able to "zoom in" a split (actually a new tab, :q to exit it)
:noremap tt :tab split<CR>

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
vnoremap <C-r> "hy:%s@<C-r>h@@gc<left><left><left>

" Screen update (force syntax hilighting sync from start too)
nnoremap <silent> <C-l> :nohlsearch<CR>:setl nolist nospell<CR>:diffupdate<CR>:syntax sync fromstart<CR><C-l>

augroup basic
    autocmd!
    autocmd BufEnter * syntax sync fromstart
augroup end

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

" Don't use two spaces when joining lines
set nojoinspaces

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
set diffopt+=vertical

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => File types
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.ad set filetype=asciidoc
autocmd BufNewFile,BufRead *.adoc set filetype=asciidoc
autocmd BufNewFile,BufRead *.asciidoc set filetype=asciidoc
autocmd FileType make setlocal noexpandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" set background=dark " Can help other plugins find correct colors
if (_sq_uid != 0)
    " colorscheme badwolf
    if &diff
        colorscheme jellybeans
    else
        colorscheme badwolf
    endif
else
    colorscheme slate
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type and don't keep dos/mac ones
set fileformats=unix

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
set formatoptions-=t
" Set lines length to 88 when using "gq"
set formatoptions+=q
set textwidth=88

set autoindent
set wrap " Wrap lines for display

" From http://vim.wikia.com/wiki/Indent_text_object
onoremap <silent>ai :<C-u>call IndTxtObj(0)<CR>
onoremap <silent>ii :<C-u>call IndTxtObj(1)<CR>
vnoremap <silent>ai <Esc>:call IndTxtObj(0)<CR><Esc>gv
vnoremap <silent>ii <Esc>:call IndTxtObj(1)<CR><Esc>gv

function! IndTxtObj(inner)
  let curcol = col(".")
  let curline = line(".")
  let lastline = line("$")
  let i = indent(line("."))
  if getline(".") !~ "^\\s*$"
    let p = line(".") - 1
    let pp = line(".") - 2
    let nextblank = getline(p) =~ "^\\s*$"
    let nextnextblank = getline(pp) =~ "^\\s*$"
    while p > 0 && ((i == 0 && (!nextblank || (pp > 0 && !nextnextblank))) || (i > 0 && ((indent(p) >= i && !(nextblank && a:inner)) || (nextblank && !a:inner))))
      -
      let p = line(".") - 1
      let pp = line(".") - 2
      let nextblank = getline(p) =~ "^\\s*$"
      let nextnextblank = getline(pp) =~ "^\\s*$"
    endwhile
    normal! 0V
    call cursor(curline, curcol)
    let p = line(".") + 1
    let pp = line(".") + 2
    let nextblank = getline(p) =~ "^\\s*$"
    let nextnextblank = getline(pp) =~ "^\\s*$"
    while p <= lastline && ((i == 0 && (!nextblank || pp < lastline && !nextnextblank)) || (i > 0 && ((indent(p) >= i && !(nextblank && a:inner)) || (nextblank && !a:inner))))
      +
      let p = line(".") + 1
      let pp = line(".") + 2
      let nextblank = getline(p) =~ "^\\s*$"
      let nextnextblank = getline(pp) =~ "^\\s*$"
    endwhile
    normal! $
  endif
endfunction

if (_sq_uid != 0)

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => vim-airline plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#fnamemod = ':t'
    let g:airline#extensions#taboo#enabled = 1
    let g:airline#extensions#hunks#non_zero_only = 1
    let g:airline_theme = 'light'
    if !empty(glob(expand('~')."/.fonts/*Powerline*")) || !empty(glob(expand('~')."/.local/share/fonts/*Powerline*"))
        let g:airline_powerline_fonts=1
    else
        let g:airline_powerline_fonts=0
        " unicode symbols
        if !exists('g:airline_symbols')
          let g:airline_symbols = {}
        endif
        let g:airline_left_sep = '▶'
        let g:airline_right_sep = '◀'
        let g:airline_symbols.paste = '▽'
        let g:airline_symbols.readonly = '❎'
        let g:airline_symbols.whitespace = 'Ξ'
        let g:airline_symbols.linenr = '¶'
        let g:airline_symbols.branch = '⎇'
        let g:airline_symbols.modified = '⚑'
        let g:airline_symbols.space = ' '
    endif
    let g:airline_section_c = '%<%F' " display full path in middle airline bar, but truncate on the left if too long
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    "let g:airline_section_x = '' " disable file format info
    " Always display status bar
    set laststatus=2
    " Use nicer symbols in the bars
    set guifont=PowerlineSymbols
    " Force command bar height to be 1 (often set otherwise by plugins)
    set cmdheight=1

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => tagbar plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    nmap <F8> :TagbarToggle<CR>
    let g:tagbar_autofocus = 1
    let g:tagbar_show_linenumbers = 1
    let g:airline#extensions#tagbar#enabled = 0

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
    let g:tagbar_type_markdown = {
        \ 'ctagstype' : 'markdown',
        \ 'kinds' : [
            \ 'h:table of contents',
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
    let g:bufExplorerFindActive=1
    let g:bufExplorerReverseSort=0
    let g:bufExplorerShowDirectories=0
    let g:bufExplorerShowNoName=0
    let g:bufExplorerShowRelativePath=0
    let g:bufExplorerShowTabBuffer=0
    let g:bufExplorerShowUnlisted=0
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
    " => gitgutter plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:gitgutter_sign_priority = 0
    let g:gitgutter_sign_added = '+'
    let g:gitgutter_sign_modified = '~'
    let g:gitgutter_sign_removed = '_'
    let g:gitgutter_sign_removed_first_line = '‾'
    let g:gitgutter_sign_modified_removed = '~'
    highlight GitGutterAdd cterm=bold ctermbg=none ctermfg=119 gui=bold
    highlight GitGutterDelete cterm=bold ctermbg=none ctermfg=197 gui=bold
    highlight GitGutterChange cterm=bold ctermbg=none ctermfg=227 gui=bold
    highlight GitGutterChangeDelete cterm=bold ctermbg=none ctermfg=215 gui=bold

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => vim-signify plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:signify_vcs_list = [ 'git', 'svn' ]
    let g:signify_update_on_bufenter = 0
    let g:signify_update_on_focusgained = 1

    " highlight signs in Signify
    highlight SignifySignAdd    cterm=bold ctermbg=none  ctermfg=119
    highlight SignifySignDelete cterm=bold ctermbg=none  ctermfg=167
    highlight SignifySignChange cterm=bold ctermbg=none  ctermfg=227

    " hunk text object
    omap ic <plug>(signify-motion-inner-pending)
    xmap ic <plug>(signify-motion-inner-visual)
    omap ac <plug>(signify-motion-outer-pending)
    xmap ac <plug>(signify-motion-outer-visual)

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => vim-session plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    set sessionoptions+=tabpages,globals
    set sessionoptions-=help,blank

    :let g:session_autoload = 'yes'
    :let g:session_autosave = 'yes'

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => HiCursorWords plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Don't hilight unless the cursor doesn't move for 1 second
    let g:HiCursorWords_delay = 1000

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => YouCompleteMe plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_global_ycm_extra_conf = '$HOME/.ycm_extra_conf.py'
    let g:ycm_confirm_extra_conf = 0
    let g:ycm_complete_in_comments = 1
    let g:ycm_always_populate_location_list = 1
    let g:ycm_max_diagnostics_to_display = 60
    let g:ycm_enable_diagnostic_highlighting = 1
    let g:ycm_enable_diagnostic_signs = 1
    let g:ycm_echo_current_diagnostic = 1
    let g:ycm_auto_hover = ''
    nmap <leader>h <Plug>(YCMHover)
    nnoremap <C-]> :YcmCompleter GoTo<CR>
    nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
    " Disable clangd support because it is not usable with .ycm_extra_conf.py yet (AttributeError: module 'ycm_core' has no attribute 'CompilationDatabase')
    " .ycm_extra_conf.py is mandatory to be able to customize the location search for json files
    let g:ycm_use_clangd = 0
    " Terrible performaces and RAM usage otherwise, on py files at least
    let g:ycm_collect_identifiers_from_tags_files = 0
    highlight YcmErrorSign cterm=bold ctermbg=none ctermfg=9 gui=bold
    highlight YcmErrorLine ctermbg=174 ctermfg=0
    highlight YcmErrorSection ctermbg=9
    highlight YcmWarningSign ctermbg=none ctermfg=208 gui=bold
    highlight YcmWarningLine ctermbg=223 ctermfg=0
    highlight YcmWarningSection ctermbg=208

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
    let g:SignaturePurgeConfirmation = 1 " avoid loosing all marks on m<space>

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => toggle_words plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    nmap <leader>t :ToggleWord<CR>

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => taboo plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:taboo_tabline=0
    let g:taboo_tab_format='[%N] %f%m'
    let g:taboo_renamed_tab_format='[%N:%l] %f%m'

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => vim-fswitch plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:fsnonewfiles='off'
    au! BufEnter *.cpp,*.cc,*.c let b:fswitchdst = 'h,hpp' | let b:fswitchlocs = 'reg:/src/include/,reg:/src/api/,reg:/src/inc/,rel:../include/,rel:../../include/,rel:../inc,rel:../../inc,rel:../api/,rel:../../api/,rel:./,rel:../,rel:../../'
    au! BufEnter *.h,*.hpp let b:fswitchdst = 'cpp,cc,c' | let b:fswitchlocs = 'reg:/include/src/,reg:/inc/src/,reg:/api/src/,rel:../src,rel:../../src,rel:./,rel:../,rel:../../'
    nmap <silent> <Leader>s :FSHere<cr>

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => ale plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    let g:ale_set_highlights=0
    let g:ale_sign_error='E>'
    let g:ale_sign_warning='W>'
    let g:ale_sign_style_error='e>'
    let g:ale_sign_style_warning='w>'
    let g:ale_sign_info='I>'
    let g:airline#extensions#ale#enabled=1
    let g:ale_set_signs=0 " for now, because it alwas messes with the gitgutter signs display, more important to me
    let g:ale_linters_explicit=1
    " Disable c/cpp checks for now (irrelevant results due to unknown flags, and redundant with YCM anyway)
    let g:ale_linters={
    \ 'c': [],
    \ 'cpp': [],
    \}

    nmap <silent> ]l :ALENext<cr>
    nmap <silent> [l :ALEPrevious<cr>

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => vim-pandoc plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    augroup pandoc_syntax
        au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
    augroup END
    let g:pandoc#syntax#conceal#use=0
    let g:pandoc#syntax#style#emphases=0
    let g:pandoc#syntax#roman_lists=0
    let g:pandoc#syntax#style#underline_special=0

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => grep plugin
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    :let Grep_Skip_Files = '*.bak *~ *.pyc *.so *.o *.a *.lib *.bin'
    nnoremap <silent> <F3> :Rgrep<CR>
    vnoremap <F3> :<C-U>
        \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
        \gvy:
        \let patt=substitute(escape(getreg('"'),'?\.*$^~['),'\_s\+','\\s\\+','g')<CR>
        \gV:call setreg('"', old_reg, old_regtype)<CR>
        \:Rgrep <C-r>=patt<CR>

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " => NERDTree
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    map <C-n> :NERDTreeToggle<CR>
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Use local .vimrc
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

