

" hybrid line numbers
set number relativenumber

" clear search highlight with escape
" nnoremap <esc> :noh<return><esc>

" shortcut exit
" fix, see  https://stackoverflow.com/a/7884226
silent !stty -ixon > /dev/null 2>/dev/null
nnoremap <C-q> <Esc>:q<CR>
inoremap <C-q> <Esc>:q<CR>

" shortcut save
nnoremap <C-s> <Esc>:w<CR>
inoremap <C-s> <Esc>:w<CR>

" shortcut save + exit
"nnoremap <C-x> <Esc>:x<CR>
"inoremap <C-x> <Esc>:x<CR>

" tabbing
nnoremap <C-t> <esc>:tabnew<CR>
inoremap <C-t> <esc>:tabnew<CR>

nnoremap <C-Right> <esc>:tabnext<CR>
inoremap <C-Right> <esc>:tabnext<CR>
nnoremap <C-Left> <esc>:tabprevious<CR>
inoremap <C-Left> <esc>:tabprevious<CR>

"  no colors
" syntax off
" set nohlsearch
" set t_Co=0

"  soft tabs 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent

"  leader key = space
let mapleader=" "

" easymotion highlight colors
hi link EasyMotionTarget Search
hi link EasyMotionTarget2First Search
hi link EasyMotionTarget2Second Search
hi link EasyMotionShade Comment

let g:ctrlp_custom_ignore = '\v[\/](\.(git|hg|svn)|node_modules)$'

call plug#begin('~/.vim/plugged')
Plug 'easymotion/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'
" Plug 'vim-scripts/project'
" Plug 'Valloric/YouCompleteMe'
" Plug 'evanram/mandevilla'
Plug 'flazz/vim-colorschemes'
Plug 'chrisbra/Colorizer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
call plug#end()

" coloring
set termguicolors     " enable true colors support
" let ayucolor="light"  " for light version of theme
colorscheme koehler

" airline configs
let g:airline_powerline_fonts = 1
