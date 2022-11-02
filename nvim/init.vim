""" Config for stable nvim-qt v0.8/unstable v0.9 //01-11-2022
"1. Plugins
"2. Global_set's
"3. autocmd
"4. Plugin_settings
"5. Functions
"6. Mappings

"§ Plugins
call plug#begin(stdpath('data') . '/plugged') "order by service, author name, repo name
    Plug 'dense-analysis/ale' "linter/fixer/...
    Plug 'dominikduda/vim_current_word' "highlighting word under cursor and all of its occurences
    Plug 'easymotion/vim-easymotion' "search-jump movement
    Plug 'ehamberg/vim-cute-python' "conceal some python operators
    Plug 'godlygeek/tabular' "called line up text
    Plug 'honza/vim-snippets' "snippets ¯\_(ツ)_/¯
        Plug 'SirVer/ultisnips' "snippet engine
    Plug 'konfekt/fastfold' "fix folding
    Plug 'mbbill/undotree' "modal undo tree visualization
    Plug 'mhinz/vim-startify' "startpage
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'} "semantic highlighting for Python
    Plug 'plasticboy/vim-markdown' "improve MD highlighting, conceal, folding
    Plug 'raimondi/delimitmate' "brackets autocomplete
    Plug 'sainnhe/everforest' "colorscheme
    Plug 'terryma/vim-expand-region' "visually select increasingly larger/smaller regions
    Plug 'tmhedberg/simpylfold' "improved python folding
    Plug 'tomtom/quickfixsigns_vim' "marks/git diff visualization
    Plug 'tpope/vim-commentary' "fast commenting plugin
    Plug 'tpope/vim-speeddating' "correct (inc/dec)rease datetime text objects
    Plug 'tpope/vim-surround' "add surround operator (eg: ds', cs'[, ysiW', yss'[ (before remap))
    Plug 'vim-airline/vim-airline' "statusbar/tabbar plugin
        Plug 'bling/vim-bufferline' "TEMPORARY
        Plug 'ryanoasis/vim-devicons' "add filetype glyphs
        Plug 'vim-airline/vim-airline-themes' "style themes
    Plug 'yuttie/comfortable-motion.vim' "smooth scrolling on (half)page up/down
    Plug 'https://gitlab.com/code-stats/code-stats-vim.git' "plugin for Code::Stats service
call plug#end()


"§ Global_set's
" UI
set signcolumn=yes "always show sign column, not only while there are errors
set number relativenumber "show line numbers; display cur line, other numbers is relative to cur
set numberwidth=5 "3 columns for thousands lines; 2 columns for linter messages
set cursorline "highlight current line
set list listchars=tab:——\ ,extends:›,precedes:‹,nbsp:·,trail: "display auxiliary symbols
set showmatch "temporarily highlight opening bracket when typed a closing
set scrolloff=6 "keep at least 6 lines between current line and top/bottom of the screen
set linebreak "line break by words, not by characters
set textwidth=98 "used by formatoptions 't','c'. 'formatoptions' controlled by ???; has auto\n
set completeopt=menuone,preview,noinsert "autocomplete menu (see :h)
set linespace=1 "number of pixel lines inserted between characters. depends on the current font
set conceallevel=2 "h: concealed text is hidden unless it has a custom replacement character
set cmdheight=2 "two lines height for the bottom command-line/output line

" key behavior
set mouse=a "enable mouse for all modes
set notimeout "disable max time to wait key code for sequence
set backspace=start "backspacing in IM over the start of ins; cannot delete linebr and autoindent
set whichwrap= "allow to move over linebr with <BS>,<Space> in NM,VM;
set wildmode=full:list "CM: show all options with one-line completion on first <Tab>
set virtualedit=onemore "allow to move just past the end of the line
set virtualedit+=block "cursor can be positioned where there is no actual character in Block VM
set matchpairs=<:>,(:),[:],{:} " %-movement; extra pairs '"` provided by 'vim-matchquote' plugin
            \ "also work for c-style /*comments*/ and '#if, ..., #endif' multiline conditions
            \ " ...but this plugin assignments cannot be remapped :c

" sessions
set sessionoptions=tabpages,folds,curdir "do not save blank,buffers,help,winsize between sessions
set undofile "save history of buffer changes between sessions
set confirm "show confirm dialog instead error when closing with unsaved changes

" tabs/indents
set tabstop=4 "1 indent level = 4<Space>
set shiftwidth=4 "1 autoindent level = 4<Space>
set softtabstop=4 "1<Tab> press send equal 4<Space>
set expandtab "use <Tab> as n<Space>

" folds
set foldlevel=3 "folds with a higher level will be closed
set foldcolumn=auto:3 "autosize left fold-column; max 3
set foldignore= "disable default unfolding lines which start with '#'

" other
set ignorecase smartcase "ignore case in search patterns (only if all characters are lowercase)
set spelllang=en_us,ru_yo "set internal en_US and ru_ё spell check without enabling
set spellfile=./utf-8.add "enable separate good/bad list for each file

" other not 'set's
syntax on
filetype plugin indent on
call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0) "for properly airline tabs work


"§ autocmd
" filetype-specific
autocmd BufEnter,BufRead,BufNewFile *.py,*.pyw let python_highlight_all=1
            \ | setlocal smartindent
            \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with,match,case
            \ | call PythonMappings()

autocmd BufEnter,BufRead,BufNewFile *.vim silent! execute 'unmap <buffer> [['
            \ | silent! execute 'unmap <buffer> []'
            \ | silent! execute 'unmap <buffer> ["'

autocmd BufEnter,BufRead,BufNewFile *.md setlocal textwidth=0

" terminal
autocmd WinLeave * if &buftype == "terminal" | bd! term | endif
autocmd BufAdd * call timer_start(66, {-> execute(
            \ 'if &buftype == "terminal" | map <silent><buffer> q :q<CR>| startinsert | endif')})

" sessions
autocmd VimLeave * if &filetype != 'startify' | try | bd! term | catch | | endtry
            \ | exe 'mksession! c:\temp\nvim\last_session.vim' | endif

" for external python script file opener to open in an existing process
autocmd VimEnter * silent execute '!echo ' . v:servername . ' > "c:\temp\nvim\servername.txt"'
autocmd VimLeave * silent execute '!del "c:\temp\nvim\servername.txt"'

" other
autocmd User ALEFixPost if &filetype == 'python' | execute('Semshi highlight')
autocmd BufWritePost *.bat,*.cmd silent execute 'w! ++enc=cp1250'
autocmd VimEnter * call GuiWindowFullScreen(1) | call PluginMappings()
autocmd BufWinEnter *.txt if &filetype == 'help' | wincmd L
            \ | execute 'map <silent><buffer> q :q<CR>' | endif
autocmd BufAdd * call timer_start(66, {-> execute(
            \ 'if len(getbufinfo({"buflisted":1})) > tabpagenr("$")
            \ && &buftype == "" && &filetype[:2] != "ale" | tab ball | endif')})
            \ "simulate behavior like 1buffer=1tab


"§ Plugin_settings
" everforest colorscheme
let g:everforest_background = 'soft'
let g:everforest_disable_italic_comment = 1
let g:everforest_better_perfomace = 1
let g:everforest_current_word = 'bold'
colorscheme everforest "(define colorsheme after it's settings)

" startify
let g:startify_bookmarks = []
for line in readfile($VIM . '\bookmarks.txt')
    call add(g:startify_bookmarks, json_decode(line))
endfor
let g:startify_commands = [
            \   {'l': [' Last session', 'call LoadSession()']},
            \ ]
let g:startify_lists = [
            \   {'type': 'files',     'header': ['      MRU']},
            \   {'type': 'sessions',  'header': ['      Sessions']},
            \   {'type': 'bookmarks', 'header': ['      Bookmarks']},
            \   {'type': 'commands',  'header': ['      Commands']},
            \ ]
let g:startify_session_before_save = ['silent! tabdo if &filetype == "help" | q | endif']
let g:startify_skiplist = ['/']
let g:startify_padding_left = 6
let g:startify_session_sort = 1
let g:startify_custom_indices = ['a', 'o', 'i', 'u', 'm', 's', 't', 'r', 'n', 'c']
let g:startify_custom_indices += map(range(1,99), 'string(v:val)')

" airline
"" nerd font symbols properly works with installed Fura_Code_RNFCM even it isn't set as nvim font
"" BUT on Win10 sysfont Segoe_UI_Symb overwrites patched font if this font isn't set as nvim font
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_section_z = ' %l/%L : %v | %{strftime("%H:%M")}'
let g:airline_theme = 'zenburn' "or base16_ashes or base16_ocean
let g:airline_highlighting_cache = 1
let g:airline_powerline_fonts = 1
let g:airline_section_x = airline#section#create_right(['tagbar', 'filetype', '%{CodeStatsXp()}'])
let g:Powerline_symbols = 'unicode'
let g:airline_extensions = ['ale', 'tabline', 'whitespace', 'wordcount']

"" airline-tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#tabs_label = ''
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_tab_count = 2
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#tab_nr_type = 1

" ale main
let g:ale_virtualtext_cursor = 1
let g:ale_hover_cursor = 0
let g:ale_list_vertical = 1
let g:ale_pattern_options = {
            \   '\.min.js$': {'ale_enabled': 0},
            \   '\.min.css$': {'ale_enabled': 0},
            \ }
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_exclude_highlights = ['[pydocstyle]']

"" ale linters
let g:ale_linters = {
            \   'python': ['bandit', 'mypy', 'pydocstyle', 'pylint', 'flake8'],
            \ }
            \ "vulture?
let g:ale_python_bandit_options = '--skip=B608'
            \ "B608 – hardcoded_sql_expressions (i.e. f”SELECT foo FROM bar WHERE id = {product}”.
let g:ale_python_mypy_options = '--ignore-missing-imports --cache-dir "c:\temp\.mypy_cache"'
            \ "disable error 'Mypy will not try inferring the types of any 3rd party libs ...';
            \ "set custom folder for mypy cache.
let g:ale_python_pydocstyle_options = '--ignore=D105,D107,D203,D213,D300'
            \ "D105 – Missing docstring in magic method;
            \ "D107 – Missing docstring in __init__;
            \ "fix conflicting D203-D211 and D212-D213;
            \ "D203/D211 – [1/No] blank line[/s] [required/allowed] before class docstring;
            \ "D212/D213 – Multi-line docstring summary should start at the [first/second] line;
            \ "D300 − Use “””triple double quotes”””.
let g:ale_python_pylint_use_msg_id = 1
let g:ale_python_pylint_options =
            \ '--disable C0103,C0411,W1203 '
            \ . '--load-plugins pylint_flask,pylint_flask_sqlalchemy,pylint_django '
            \ . '--persistent n'
            \ "C0103 – Constant name ... doesn't conform to UPPER_CASE naming style;
            \   "but C0103 react on local 'temporarily-constants' which aren't really constants;
            \ "C0411 – Standard import 'from ...' should be placed before 'import ...';
            \ "W1203 – Use %s formatting in logging functions;
            \ "Add flask, flask-sqlalchemy and django support;
            \ "Disable incorrect generation .stats files.
let g:ale_python_flake8_options =
            \ '--max-line-length=99 --ignore=E203,W503'

"" ale fixers
let g:ale_fixers = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'python': ['black', 'isort'],
            \   'css': ['css-beautify'],
            \ }
let g:ale_python_black_options =
            \ '-S -C -l 99'
            \ "allow to use single-quote character on docstrings;
            \ "disable comma after last list element; \\it doesn't work?
            \ "set line length.

" easy motion
let g:EasyMotion_keys = 'EAOIUMSTRNCQPHYWDLVJKGFB'
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_use_upper = 1
let g:EasyMotion_smartcase = 1

" other
let g:quickfixsigns_echo_map = ''
let g:quickfixsigns_classes = ['qfl', 'loc', 'marks', 'breakpoints']
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:bufferline_echo = 0 "disable additional echo on the command-line
let g:codestats_api_key = $CODESTATS_API_KEY
let g:semshi#mark_selected_nodes = 0
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_ShortIndicators = 1
let g:expand_region_text_objects = {
            \ 'iw': 0, 'iW': 0, 'i"': 1, 'i''': 1, 'i]': 1,
            \ 'ib': 1, 'iB': 1, 'il': 1, 'ip': 1, 'ie': 0,
            \ }
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
            \   '.ahk*': '',
            \   '.py*': '',
            \ } "devicons additional file extensions


"§ Functions
function LoadSession()
    """Restore last autosaved session. Called by Startify menu."""
    if (filereadable(expand('c:\temp\nvim\last_session.vim')))
        silent! exe 'source c:\temp\nvim\last_session.vim'
        silent! call DeleteEmptyBuffers()
    else
        echo 'No session loaded'
    endif
endfunction

function DeleteEmptyBuffers()
    """Called from LoadSession() to avoid empty buffers bug on load."""
    let [i, n; empty] = [1, bufnr('$')]
    while i <= n
        if bufexists(i) && bufname(i) == ''
            call add(empty, i)
        endif
        let i += 1
    endwhile
    if len(empty) > 0
        exe 'bdelete' join(empty)
    endif
endfunction

let s:is_maximized = 1
function MaximizeToggle()
    """Toggle fullscreen mode. Mapped on <F11>."""
    let s:is_maximized = !s:is_maximized
    call GuiWindowFullScreen(s:is_maximized)
endfunction

let s:is_opacity_set = 0
function OpacityToggle()
    """Toggle opacity (80%/100%)."""
    let s:is_opacity_set = !s:is_opacity_set
    execute('GuiWindowOpacity' . string(1-s:is_opacity_set/5.0))
endfunction

function UnMinify()
    """Restore minified files to exploitable view. Not mapped, call this directly."""
    %s/{\ze[^\r\n]/{\r/g
    %s/){/) {/g
    %s/};\?\ze[^\r\n]/\0\r/g
    %s/;\ze[^\r\n]/;\r/g
    %s/[^\s]\zs[=&|]\+\ze[^\s]/ \0 /g
    normal ggVG=
endfunction


"§ Mappings
" custom mappings for qPhyx layout with symbol layers

function PluginMappings()
    """Un/remap conflicting plugin mappings."""
    execute 'nmap ea' maparg('cs', 'n')
    execute 'nmap ua' maparg('ds', 'n')
    execute 'nmap ha' maparg('ys', 'n')
    execute 'nmap hao' maparg('yss', 'n')
    " ru
    execute 'nmap еа' maparg('cs', 'n')
    execute 'nmap уа' maparg('ds', 'n')
    execute 'nmap ха' maparg('ys', 'n')
    execute 'nmap хао' maparg('yss', 'n')

    unmap [z
    unmap [%
    unmap ys
    unmap yS
    unmap yss
    unmap ySs
    unmap ySS
    unmap cs
    unmap cS
    unmap ds
    unmap d<C-a>
    unmap d<C-x>
    unmap gx
    unmap gS
    unmap gc
    unmap gcu
    unmap gcc
    unmap g%
    unmap <C-a>
    unmap <C-x>
    noremap % ^
    noremap + C
    vmap S <nop>
    vmap T <nop>
    nmap <silent> S :call comfortable_motion#flick(100)<CR>
    nmap <silent> T :call comfortable_motion#flick(-100)<CR>
    " ru
    nmap <silent> С :call comfortable_motion#flick(100)<CR>
    nmap <silent> Т :call comfortable_motion#flick(-100)<CR>
endfunction

function PythonMappings()
    silent! unmap <buffer> [[
    silent! unmap <buffer> []
    silent! unmap <buffer> [m
    silent! unmap <buffer> [M
    nnoremap <silent> <buffer> ;f :ALEFix<CR>
    nnoremap <silent> <buffer> ;w :ALEPreviousWrap<CR>
    nnoremap <silent> <buffer> ;d :ALENextWrap<CR>
    nnoremap <silent> <buffer> ;r :Semshi rename<CR>
    nnoremap <silent> <buffer> ;c :Semshi highlight<CR>
    nnoremap <silent> <buffer> ;e :Semshi error<CR>
    nnoremap <silent> <buffer> ;u :Semshi goto unresolved first<CR>
    nnoremap <silent> <buffer> ;a :Semshi goto parameterUnused<CR>
    nnoremap <silent> <buffer> ;o :Semshi goto class prev<CR>
    nnoremap <silent> <buffer> ;i :Semshi goto class next<CR>
    nnoremap <silent> <buffer> w :Semshi goto function prev<CR>
    nnoremap <silent> <buffer> d :Semshi goto function next<CR>
    " ru
    nnoremap <silent> <buffer> ;ф :ALEFix<CR>
    nnoremap <silent> <buffer> ;ш :ALEPreviousWrap<CR>
    nnoremap <silent> <buffer> ;д :ALENextWrap<CR>
    nnoremap <silent> <buffer> ;р :Semshi rename<CR>
    nnoremap <silent> <buffer> ;ц :Semshi highlight<CR>
    nnoremap <silent> <buffer> ;е :Semshi error<CR>
    nnoremap <silent> <buffer> ;у :Semshi goto unresolved first<CR>
    nnoremap <silent> <buffer> ;а :Semshi goto parameterUnused<CR>
    nnoremap <silent> <buffer> ;о :Semshi goto class prev<CR>
    nnoremap <silent> <buffer> ;и :Semshi goto class next<CR>
    nnoremap <silent> <buffer> ш :Semshi goto function prev<CR>
    nnoremap <silent> <buffer> д :Semshi goto function next<CR>
endfunction


" global/misc
command Term below split | resize 20 | term
map <F10> :call OpacityToggle()<CR>
map <F11> :call MaximizeToggle()<CR>
tnoremap <Esc> <C-\><C-n>

" right click context menu (copy-cut-paste)
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv

" disable basic mappings
map * <nop>
map { <nop>
map ; <nop>
map ` <nop>
map ' <nop>
map - <nop>
map _ <nop>
map ) <nop>
map } <nop>
map u <nop>
map £ <nop>
map <C-r> <nop>
map <C-t> <nop>
map <C-y> <nop>
map <C-e> <nop>
map <C-n> <nop>
map <C-v> <nop>
map <C-q> <nop>
map <C-i> <nop>
map <C-o> <nop>
map <C-p> <nop>
map <C-g> <nop>
map <C-h> <nop>
map <C-j> <nop>
map <C-c> <nop>
map <C-z> <nop>
map <Bar> <nop>
map kv <nop>
vmap q <nop>
vmap y <nop>
map <A-CR> <nop>
map  <nop>

" movement
noremap m h
noremap M b
"" noremap % ^ " PM()
noremap <Left> B
noremap s j
noremap t k
noremap r l
noremap R w
noremap , $
noremap <Right> W
noremap n f
noremap N F
noremap l %
noremap c ;
noremap C ,
noremap <CR> +
noremap <S-CR> -

" jump
noremap <Tab> *
noremap <S-Tab> #
noremap <BS> `
noremap <BS><BS> ``
noremap w {
noremap W <C-o>
noremap d }
noremap D <C-i>
noremap v G
noremap ! gD
noremap f n
noremap F N
noremap g L
noremap G H
noremap > M
noremap B /
"" map b <Plug>(easymotion-sn)
"" nmap <Space>... <Plug>(easymotion-...)

" visual
noremap j v
noremap J V
noremap $ <C-v>
noremap ¢ gv
"" map € <Plug>(expand_region_shrink)
"" map ₽ <Plug>(expand_region_expand)

" change
"" nmap q <Plug>SpeedDatingUp   " increase number/date
"" nmap Q <Plug>SpeedDatingDown " decrease number/date
noremap ~ gU
noremap ° gu
"" default p/P
noremap – gp
noremap — gP
noremap H ~
noremap ’ g~
nnoremap y u
noremap Y <C-r>
nnoremap \ u
nnoremap & U
noremap x >
noremap X <
noremap @ J
noremap § gJ
noremap # gc
noremap e c
nnoremap ee cc
noremap E r
"" noremap + C " PM()
nnoremap ± R
nnoremap a .
nnoremap A &
"" default o/O
"" default i/I
noremap / A
nnoremap ÷ 0i
noremap u d
nnoremap uu dd
noremap U x
noremap = X
noremap ≠ "_d
nnoremap ≠≠ "_dd

" window
noremap ( gT
noremap [ gt
"" nmap <silent> S :call comfortable_motion#flick(100)<CR>  " PM()
noremap " zb
noremap <Down> <C-e>
"" nmap <silent> T :call comfortable_motion#flick(-100)<CR> " PM()
noremap . zt
noremap <Up> <C-y>
noremap   zz

" other
noremap h y
nnoremap hh yy
nnoremap ' yy
noremap z @
noremap Z q
noremap < @@
noremap L "
nnoremap { :reg<CR>
"" default :
noremap ^ @:
noremap <Del> m
nnoremap ? :noh<CR>
nnoremap q :set nospell<CR>
nnoremap p :set spell<CR>
nnoremap h zg
nnoremap y zw
nnoremap f :f<CR>
noremap t :Tabularize /
nnoremap  :echo strftime('%c')<CR>
nnoremap <silent>s :tab new <bar> Startify<CR>
noremap <F1> :UndotreeToggle<CR>

" folds
noremap zA <nop>
noremap zC <nop>
noremap zD <nop>
noremap zE <nop>
noremap zf <nop>
noremap zo <nop>
noremap za <nop>
noremap zc <nop>
noremap zd <nop>
noremap zm <nop>
noremap zr <nop>
noremap kk za
noremap ku zd
noremap km zc
noremap kr zo
noremap ke zf
noremap k! zE
noremap ks zm
noremap kt zr

" splits
noremap <C-w>m <C-w>h
noremap <C-w>s <C-w>j
noremap <C-w>t <C-w>k
noremap <C-w>r <C-w>l
noremap <C-w>h <C-w>s
noremap <C-w>u <C-w>c
noremap <C-w><Space> <C-w>w
noremap <C-w>j <nop>
noremap <C-w>k <nop>
noremap <C-w>l <nop>
noremap <C-w>b <nop>
noremap <C-w>c <nop>

" <Plug>
nmap q <Plug>SpeedDatingUp
nmap Q <Plug>SpeedDatingDown
map € <Plug>(expand_region_shrink)
map ₽ <Plug>(expand_region_expand)
map V <Plug>Commentary
nmap VV <Plug>CommentaryLine

vmap <Space><Space> <Plug>(easymotion-sn)
nmap <Space><Space> <Plug>(easymotion-overwin-f2)
nmap <Space>s <Plug>(easymotion-overwin-line)
nmap <Space>r <Plug>(easymotion-overwin-w)
map b <Plug>(easymotion-sn)

" insert mode
"" qwerty-view (ง'̀-'́)ง
inoremap <C-BS> <C-w>
inoremap <C-f> <C-a>
inoremap <C-q> <C-d>
inoremap <C-w> <C-t>
inoremap <C-a> <C-e>
inoremap <C-s> <C-y>
inoremap <C-d> <C-o>
inoremap <C-v> <C-r>
inoremap <C-v><C-v> <C-v>
inoremap <C-z> <C-o>u
inoremap   <C-n>
"" media keys
inoremap  <nop>
inoremap  <nop>
inoremap  <nop>
inoremap  <nop>
inoremap  <nop>

" command mode
cnoremap <C-v> <C-r>
cnoremap <C-v><C-f> <C-r><C-w>
cnoremap <C-v><C-v> <C-v>


" ru-layout duplicates
"" movement
noremap м h
noremap М b
noremap с j
noremap т k
noremap р l
noremap Р w
noremap н f
noremap Н F
noremap л %
noremap ц ;
noremap Ц ,

"" jump
noremap ш {
noremap Ш <C-o>
noremap д }
noremap Д <C-i>
noremap в G
noremap ф n
noremap Ф N
noremap г L
noremap Г H
noremap Б /

"" visual
noremap й v
noremap Й V

"" change
noremap п p
noremap П P
noremap Х ~
nnoremap ы u
noremap Ы <C-r>
noremap я >
noremap Я <
noremap е c
nnoremap ее cc
noremap Е r
nnoremap а .
nnoremap А &
nnoremap о o
nnoremap О O
nnoremap и i
nnoremap И I
noremap у d
nnoremap уу dd
noremap У x

"" other
noremap х y
nnoremap хх yy
noremap з @
noremap З q
noremap Л "
nnoremap эю :set nospell<CR>
nnoremap ёю :set nospell<CR>
nnoremap эп :set spell<CR>
nnoremap ёп :set spell<CR>
nnoremap эх zg
nnoremap ёх zg
nnoremap эы zw
nnoremap ёы zw
nnoremap эф :f<CR>
nnoremap ёф :f<CR>
noremap эт :Tabularize /
noremap ёт :Tabularize /
nnoremap <silent>эс :tab new <bar> Startify<CR>
nnoremap <silent>ёс :tab new <bar> Startify<CR>

"" folds
noremap кк za
noremap ку zd
noremap км zc
noremap кр zo
noremap ке zf
noremap к! zE
noremap кс zm
noremap кт zr

"" splits
noremap <C-w>м <C-w>h
noremap <C-w>с <C-w>j
noremap <C-w>т <C-w>k
noremap <C-w>р <C-w>l
noremap <C-w>х <C-w>s
noremap <C-w>у <C-w>c

"" <Plug>
nmap ю <Plug>SpeedDatingUp
nmap Ю <Plug>SpeedDatingDown
map В <Plug>Commentary
nmap ВВ <Plug>CommentaryLine
map б <Plug>(easymotion-sn)
