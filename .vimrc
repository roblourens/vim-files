set softtabstop=4
set linebreak
set guicursor+=a:blinkon0
set shiftwidth=4
set tabstop=4
set expandtab
set noautoindent
set smartindent
syntax enable

set number
set ai

map <S-Enter> O<Esc>
map <CR> o<Esc>
map <C-l> <C-w>l
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
nmap <SPACE> <SPACE>:noh<CR>

"highlight current line
set cul

set guifont=Monaco

call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" enable close tag plugin only on html-like files
autocmd FileType html,htmldjango,jinjahtml,eruby,mako let b:closetag_html_style=1
autocmd FileType html,xhtml,xml,htmldjango,jinjahtml,eruby,mako source ~/.vim/bundle/closetag/plugin/closetag.vim

set colorcolumn=80
