" Syntax and other visual configurations
syntax on " Enable syntax highlighting
set number " Display line numbers
set mouse=a " Enable mouse usage
set ruler " Display cursor position

" Indentation
set autoindent " Auto-indent new lines
set copyindent " Copy indent from current line

" Command maps
command! Q q " Map Q to q command
command! W w "Map W to w command

" Line lenght alerts
set colorcolumn=80 " Highlight 80th column
highlight ColorColumn ctermbg=0 guibg=lightgrey " Set color for ColorColum
match ColorColumn "\%>79v.\+" " Highlight characters beyond 80th column

" Searching commands
set ignorecase " Make searches case-insensitive
set hlsearch " Highlights all search matches
set incsearch " Shows search matches as you type

" Autocompletition settings
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Other
set showmatch " Shows matching brackets
set wildmenu "Enables command-line completion
set nowritebackup " Don't create backup before writing
