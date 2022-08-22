""" Plugin manager (dein.vim)

filetype plugin indent on
syntax enable

if &compatible
  set nocompatible " Be iMproved
endif

let s:_session_is_root = system('id -u') == 0
let s:_dein_vim_path = expand('~')."/.vim/plugin_manager/dein.vim"
let s:_plugins_path = expand('~')."/.vim/bundles"
let s:_debug_lsp = v:false

" Helpers

function! s:prefix(str, args) abort
    return map(a:args, {_, s -> a:str . s})
endfunction

function! s:suffix(str, args) abort
    return map(a:args, {_, s -> s . a:str})
endfunction

" Plugins

function s:install_plugins()
    if !isdirectory(s:_dein_vim_path)
        echom "Please install the plugins manager first. Use the install.sh script."
        exit 1
    endif
    execute "set runtimepath+=".s:_dein_vim_path
    call dein#begin(s:_plugins_path)
    if !has('nvim')
        call dein#add('roxma/nvim-yarp')
        call dein#add('roxma/vim-hug-neovim-rpc')
    endif

    """ General management

    " Let dein manage itself
    call dein#add(s:_dein_vim_path)
    " Manage dein plugins with commands
    call dein#add('haya14busa/dein-command.vim', {
        \ 'lazy': v:true,
        \ 'on_cmd': 'Dein',
    \ })
    " Vim buffers session management
    call dein#add('xolox/vim-misc', {
        \ 'if': !&diff,
    \ })
    call dein#add('xolox/vim-session', {
        \ 'if': !&diff,
    \ })

    """ Visual mods: display, themes, windows, panes

    " Dark theme, standard
    call dein#add('sjl/badwolf', {
        \ 'if': !&diff,
    \ })

    " Dark theme with arguably 'better' colors for diff panes
    call dein#add('nanotech/jellybeans.vim', {
        \ 'if': &diff,
    \ })
    " Title and Status bar tuning
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    " Highlight trailing whitespaces
    call dein#add('bronson/vim-trailing-whitespace')
    " Display vim marks in the left margin
    call dein#add('kshenoy/vim-signature', {
        \ 'if': has('signs'),
    \ })
    " Add glyphs support for other plugins
    call dein#add('ryanoasis/vim-devicons')
    " Tag bar (quickly view the classes/functions/vars in a file, and jump there)
    call dein#add('majutsushi/tagbar', {
        \ 'if': !&diff && executable('ctags'),
        \ 'lazy' : v:true,
        \ 'on_cmd' : 'TagbarToggle',
    \ })
    " Indentation vertical visual guides
    call dein#add('nathanaelkane/vim-indent-guides', {
        \ 'if': !&diff,
    \ })
    " Utilities for tabs
    call dein#add('gcmt/taboo.vim', {
        \ 'if': !&diff,
    \ })
    " Display colors on color names/codes
    call dein#add('chrisbra/Colorizer', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': s:prefix('Color', ['Highlight', 'Toggle']) + ['RGB2Term', ],
    \ })

    """ Navigation and buffers management

    " Quickly view open buffers and switch between them
    call dein#add('ctribout/bufexplorer', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': s:prefix('BufExplorer', ['', 'HorizontalSplit', 'VerticalSplit']),
    \ })
    " The NERD tree allows to explore the filesystem and to open files and directories
    call dein#add('scrooloose/nerdtree', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': s:prefix('NERDTree', ['', 'Toggle', 'Find', 'Focus']),
    \ })
    " Grep utilities
    call dein#add('yegappan/grep', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': s:prefix('Grep', ['', 'Add', 'Args', 'ArgsAdd', 'Buffer', 'BufferAdd']) + ['Rgrep', 'RgrepAdd', 'Bgrep', 'BgrepAdd', 'Rg', 'RgAdd'],
    \ })
    " Diff blocks instead of full files
    call dein#add('AndrewRadev/linediff.vim', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': s:prefix('Linediff', ['', 'Add', 'Last', 'Merge', 'Pick', 'Reset', 'Show']),
    \ })

    """ Editor helpers

    " Toggle words (change 'True' to 'False', ...)
    call dein#add('vim-scripts/toggle_words.vim', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd': 'ToggleWord',
    \ })
    " Code comments
    call dein#add('tomtom/tcomment_vim', {
        \ 'if': !&diff,
    \ })
    " Highlight the word currently on the cursor
    call dein#add('reidHoruff/HiCursorWords')
    " Navigate through indent levels
    call dein#add('kamou/vim-indentwise', {
        \ 'if': !&diff,
    \ })
    " New text objects based on indentation levels
    call dein#add('michaeljsmith/vim-indent-object', {
        \ 'if': !&diff,
        \ 'on_ft': ['ledger', 'moon', 'nim', 'python'],
        \ 'on_map': {'ov': ['aI', 'ai', 'iI', 'ii']},
    \ })
    " Inner-line text object
    call dein#add('vim-utils/vim-line', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_map': {'ov': '_'},
    \ })
    " Even more text objects
    call dein#add('wellle/targets.vim')

    """ Git-related plugins

    " Better commit message window
    call dein#add('rhysd/committia.vim', {
        \ 'if': !&diff,
    \ })
    " Show git diffs while editing (changes/removed/added lines)
    " call dein#add('mhinz/vim-signify')
    call dein#add('airblade/vim-gitgutter', {
        \ 'if': !&diff,
    \ })
    " Git wrapper, for integration with vim-airline (branch and commits in statusbar)
    call dein#add('tpope/vim-fugitive', {
        \ 'if': !&diff,
    \ })
    " Git history for the line under the cursor
    call dein#add('rhysd/git-messenger.vim', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_cmd' : 'GitMessenger',
        \ 'on_map' : '<Plug>(git-messenger',
    \ })

    """ Syntax or language-specific support

    " jinja2 syntax
    call dein#add('Glench/Vim-Jinja2-Syntax', {
        \ 'if': !&diff,
    \ })
    " Markdown support
    call dein#add('vim-pandoc/vim-pandoc-syntax', {
        \ 'if': !&diff,
    \ })
    " CMake syntax color
    call dein#add('pboettch/vim-cmake-syntax', {
        \ 'if': !&diff,
        \ 'lazy' : v:true,
        \ 'on_ft': 'cmake',
    \ })
    " Rust support
    " call dein#add('rust-lang/rust.vim', {
    "     \ 'if': !&diff,
    " \ })

    """ LSP (language server protocol)

    call dein#add('prabirshrestha/vim-lsp', {
        \ 'if': !&diff,
    \ })
    call dein#add('prabirshrestha/asyncomplete.vim', {
        \ 'if': !&diff,
    \ })
    call dein#add('prabirshrestha/asyncomplete-lsp.vim', {
        \ 'if': !&diff,
    \ })
    " Note: the needed software is installed locally, but they should be installed in
    " projects' virtual environments so that they work with their correct project
    " configuration files too (vim must be launched in that venv)
    call dein#add('mattn/vim-lsp-settings', {
        \ 'if': !&diff,
    \ })

    call dein#end()

    " Install missing plugins at startup
    if dein#check_install()
        call dein#install()
    endif

endfunction

if ! s:_session_is_root
    " Note that the test should be useless as dein.vim should prevent loading plugins in
    " root mode but for the ones with 'trusted' = v:true
    call s:install_plugins()
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto indent was needed somehow for dein.vim, but that's a pain (for yaml, python, ...) so disable it
filetype indent off

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
" show command in bottom bar (slows down the interface with pg up/down)
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

" Theme
if &diff && dein#is_available('jellybeans.vim')
    colorscheme jellybeans
elseif !&diff && dein#is_available('badwolf')
    colorscheme badwolf
else
    colorscheme slate
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type and don't keep dos/mac ones
set fileformats=unix

if !empty(glob(expand('~')."/.fonts/*Literation*Nerd*")) || !empty(glob(expand('~')."/.local/share/fonts/*Literation*Nerd*"))
    let s:airline_powerline_fonts = v:true
    set guifont=LiterationMono\ Nerd\ Font\ Book\ 11
else
    let s:airline_powerline_fonts = v:false
endif


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
set comments=s1:/*,mb:*,ex:*/,://,b:#,:%
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

" Enable syntax highlighting when buffers are displayed in a window through
" :argdo and :bufdo, which disable the Syntax autocmd event to speed up
" processing.
" from https://stackoverflow.com/questions/12485981/syntax-highlighting-is-not-turned-on-in-vim-when-opening-multiple-files-using-ar
augroup EnableSyntaxHighlighting
    autocmd! BufWinEnter,WinEnter * nested if exists('syntax_on') && ! exists('b:current_syntax') && ! empty(&l:filetype) && index(split(&eventignore, ','), 'Syntax') == -1 | syntax enable | endif
    autocmd! BufRead * if exists('syntax_on') && exists('b:current_syntax') && ! empty(&l:filetype) && index(split(&eventignore, ','), 'Syntax') != -1 | unlet! b:current_syntax | endif
augroup END

""" Plugins setting

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-airline plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-airline')
    let g:airline_skip_empty_sections = v:true
    let g:airline_section_c = '%<%F' " display full path in middle airline bar, but truncate on the left if too long
    "let g:airline_section_x = '' " disable file format info
    let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]' " Only show unusual encodings

    let g:airline_theme = 'light'
    if s:airline_powerline_fonts
        " unicode symbols
        if !exists('g:airline_symbols')
          let g:airline_symbols = {}
        endif
        let g:airline_left_sep = "\uE0B0"
        let g:airline_left_alt_sep = "\uE0B1"
        let g:airline_right_sep = "\uE0B2"
        let g:airline_right_alt_sep = "\uE0B3"
        let g:airline_symbols.paste = '▽'
        let g:airline_symbols.readonly = ''
        let g:airline_symbols.whitespace = 'Ξ'
        let g:airline_symbols.linenr = "\uE0A1"
        let g:airline_symbols.maxlinenr = ''
        let g:airline_symbols.colnr = "\uE0A3"
        let g:airline_symbols.branch = '⎇'
        let g:airline_symbols.modified = '⚑'
        let g:airline_symbols.space = ' '
    endif
    " Always display status bar
    set laststatus=2
    " Force command bar height to be 1 (often set otherwise by plugins)
    set cmdheight=1
    " Extensions
    let g:airline#extensions#tabline#enabled = v:true
    let g:airline#extensions#tabline#fnamemod = ':t'
    let g:airline#extensions#tabline#buffer_min_count = 2
    let g:airline#extensions#tabline#overflow_marker = '…'
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    let g:airline#extensions#taboo#enabled = v:true
    let g:airline#extensions#hunks#non_zero_only = v:true
    " when set, displays the virtualenv based on VIRTUAL_ENV, even if the poet-v
    " specific extension is not installed
    let g:airline#extensions#poetv#enabled = v:true
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => tagbar plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('tagbar')
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
endif



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => commitia plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('committia.vim')
    " Can trigger issue with vim-fugitive otherwise
    let g:committia_open_only_vim_starting = 1
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => git-messenger plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('git-messenger.vim')
    nmap <Leader>gm <Plug>(git-messenger)
    let g:git_messenger_always_into_popup = v:true
    let g:git_messenger_include_diff = 'all'
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => bufexplorer plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('bufexplorer')
    let g:_buffers_startup_reloaded = 0
    function _sq_bufexplorer_shortcut()
        " Display the bufexplorer windows, but reload all buffers at first attempt.
        " Necessary because bufexplorer doesn't know about buffers at startup when a
        " session was restored via vim-restored, and doesn't display much in that case
        if g:_buffers_startup_reloaded == 0
            let g:_buffers_startup_reloaded = 1
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
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => gitgutter plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-gitgutter')
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
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-signify plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-signify')
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
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-session plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-session')
    set sessionoptions+=tabpages,globals
    set sessionoptions-=help,blank

    let g:session_autoload = 'yes'
    let g:session_autosave = 'yes'
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HiCursorWords plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('HiCursorWords')
    " Don't hilight unless the cursor doesn't move for 1 second
    let g:HiCursorWords_delay = 1000
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-indent-guides plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-indent-guides')
    let g:indent_guides_start_level = 2
    let g:indent_guides_guide_size = 4
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_auto_colors = 0
    " set indent colors: very light (not visible AT ALL on gvim though...)
    hi IndentGuidesOdd  ctermbg=233
    hi IndentGuidesEven ctermbg=234
    let g:indent_guides_color_change_percent=100
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-signature plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-signature')
    let g:SignaturePurgeConfirmation = 1 " avoid loosing all marks on m<space>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => toggle_words plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('toggle_words.vim')
    nmap <leader>t :ToggleWord<CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => taboo plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('taboo.vim')
    let g:taboo_tabline=0
    let g:taboo_tab_format='[%N] %f%m'
    let g:taboo_renamed_tab_format='[%N:%l] %f%m'
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-fswitch plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('derekwyatt/vim-fswitch')
    let g:fsnonewfiles='off'
    au! BufEnter *.cpp,*.cc,*.c let b:fswitchdst = 'h,hpp' | let b:fswitchlocs = 'reg:/src/include/,reg:/src/api/,reg:/src/inc/,rel:../include/,rel:../../include/,rel:../inc,rel:../../inc,rel:../api/,rel:../../api/,rel:./,rel:../,rel:../../'
    au! BufEnter *.h,*.hpp let b:fswitchdst = 'cpp,cc,c' | let b:fswitchlocs = 'reg:/include/src/,reg:/inc/src/,reg:/api/src/,rel:../src,rel:../../src,rel:./,rel:../,rel:../../'
    nmap <silent> <Leader>s :FSHere<cr>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-pandoc plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-pandoc-syntax')
    augroup pandoc_syntax
        au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
    augroup END
    let g:pandoc#syntax#conceal#use=0
    let g:pandoc#syntax#style#emphases=0
    let g:pandoc#syntax#roman_lists=0
    let g:pandoc#syntax#style#underline_special=0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => grep plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('grep')
    :let Grep_Skip_Files = '*.bak *~ *.pyc *.so *.o *.a *.lib *.bin'
    nnoremap <silent> <F3> :Rgrep<CR>
    vnoremap <F3> :<C-U>
        \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
        \gvy:
        \let patt=substitute(escape(getreg('"'),'?\.*$^~['),'\_s\+','\\s\\+','g')<CR>
        \gV:call setreg('"', old_reg, old_regtype)<CR>
        \:Rgrep <C-r>=patt<CR>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('nerdtree')
    map <C-n> :NERDTreeToggle<CR>
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => asyncomplete.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('asyncomplete.vim')
    let g:asyncomplete_auto_popup = 1
    let g:asyncomplete_auto_completeopt = 1
    set completeopt=menuone,noinsert,noselect,preview
    " Auto close preview when completion is done
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
    " Use tab completion
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-lsp-settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-lsp-settings')
    " https://opensourcelibs.com/lib/vim-lsp-settings
    let g:lsp_settings_servers_dir = expand('~').'/.vim/vim-lsp-settings/servers'
    let g:lsp_settings_filetype_cmake = 'cmake-language-server'
    let g:lsp_settings_filetype_python = 'pylsp'
    let g:lsp_settings_filetype_sh = 'bash-language-server'
    let g:lsp_settings_filetype_tex = 'texlab'
    let g:lsp_settings_filetype_vim = 'vim-language-server'
    " pylsp settings available:
    " https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    let g:lsp_settings = {
        \ 'bash-language-server': {
            \ 'disabled': ! executable('bash-language-server'),
        \ },
        \ 'clangd': {
            \ 'disable': ! executable('clangd'),
            \ 'args': [],
        \ },
        \ 'cmake-language-server': {
            \ 'disabled': ! executable('cmake-language-server'),
        \ },
        \ 'pylsp': {
            \ 'disable': ! executable('pylsp'),
            \ 'workspace_config': {'pylsp': {
                \ 'plugins': {
                    \ 'pylint': {'enabled': v:true},
                    \ 'jedi': {'use_pyenv_environment': v:true},
                    \ 'flake8': {'enabled': v:false},
                    \ 'mccabe': {'enabled': v:false},
                    \ 'pycodestyle': {'enabled': v:false},
                    \ 'pydocstyle': {'enabled': v:false},
                    \ 'pyflakes': {'enabled': v:false},
                    \ 'yapf': {'enabled': v:false},
                \ },
            \ }},
        \ },
        \ 'remark-language-server': {
            \ 'disabled': v:true,
        \ },
        \ 'texlab': {
            \ 'disabled': ! executable('texlab'),
        \ },
        \ 'vim-language-server': {
            \ 'disabled': ! executable('vim-language-server'),
        \ },
    \ }
    " note for later: clangd option --all-scopes-completion for version >= 10
    if s:_debug_lsp
        let g:lsp_settings.clangd.args += ['--log=verbose']
        let g:lsp_settings.pylsp.args = ['-v', '-v', '--log-file', expand('~/.vim/pylsp.log')]
    endif

endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-lsp-settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if dein#is_available('vim-lsp')
    let g:lsp_fold_enabled = 0
    let g:lsp_diagnostics_enabled = 1
    " TODO: redundant with hilightcursor?
    let g:lsp_document_highlight_enabled = 1
    let g:lsp_completion_documentation_enabled = 1
    let g:lsp_completion_documentation_delay = 120
    let g:lsp_diagnostics_signs_priority = 9
    let g:lsp_diagnostics_echo_cursor = 1
    let g:lsp_diagnostics_highlights_enabled = 0
    let g:lsp_diagnostics_highlights_insert_mode_enabled = 0
    let g:lsp_diagnostics_highlights_delay = 1000
    let g:lsp_diagnostics_signs_enabled = 1
    if s:airline_powerline_fonts
        let g:lsp_diagnostics_signs_error = {'text': '✗'}
        let g:lsp_diagnostics_signs_warning = {'text': '⚠'}
        let g:lsp_diagnostics_signs_information = {'text': "\uF7FC"}
        let g:lsp_diagnostics_signs_hint = {'text': "\uF835"}
    endif
    if has('patch-8.1.1517') || has('nvim')
        " Support for float windows
        let g:lsp_preview_float = 1
        let g:lsp_preview_autoclose = 1
        let g:lsp_signature_help_enabled = 1
        let g:lsp_diagnostics_float_cursor = 1
    else
        let g:lsp_preview_float = 0
        let g:lsp_diagnostics_float_cursor = 0
        let g:lsp_signature_help_enabled = 0
    endif
    let g:lsp_diagnostics_virtual_text_enabled = 0
    let g:lsp_diagnostics_virtual_text_insert_mode_enabled = 0
    let g:lsp_hover_conceal = 0
    let g:lsp_format_sync_timeout = 1000
    if s:_debug_lsp
        let g:lsp_log_verbose = 1
        let g:lsp_log_file = expand('~/.vim/vim-lsp.log')
        let g:asyncomplete_log_file = expand('~/.vim/asyncomplete.log')
    endif

    nmap gd <plug>(lsp-definition)
    nmap gr <plug>(lsp-references)
    " nmap <buffer> gs <plug>(lsp-document-symbol-search)
    " nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    " nmap gi <plug>(lsp-implementation)
    " nmap gy <plug>(lsp-type-definition)
    nmap gh <plug>(lsp-switch-source-header)
    nmap <Leader>lf <Plug>(lsp-document-format)
    vmap <Leader>lf <Plug>(lsp-document-range-format)
    nmap [g <plug>(lsp-previous-diagnostic)
    nmap ]g <plug>(lsp-next-diagnostic)
    nmap K <plug>(lsp-hover)
    " https://github.com/prabirshrestha/vim-lsp/issues/1263#issuecomment-1011892059
    nmap <plug>() <Plug>(lsp-float-close)
    nnoremap <expr><c-f> lsp#scroll(+4)
    nnoremap <expr><c-d> lsp#scroll(-4)
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Also load local .vimrc if available
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

