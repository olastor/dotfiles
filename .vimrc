
" hybrid line numbers
set number relativenumber

" shortcut exit
" fix, see  https://stackoverflow.com/a/7884226
silent !stty -ixon > /dev/null 2>/dev/null
nnoremap <C-q> <Esc>:q<CR>
inoremap <C-q> <Esc>:q<CR>

" shortcut save
nnoremap <C-s> <Esc>:w<CR>
inoremap <C-s> <Esc>:w<CR>

" shirtcut save + exit
nnoremap <C-x> <Esc>:x<CR>
inoremap <C-x> <Esc>:x<CR>

" tabbing
nnoremap <C-t> <esc>:tabnew<CR>
inoremap <C-t> <esc>:tabnew<CR>

nnoremap <PageUp> <esc>:tabnext<CR>
inoremap <PageUp> <esc>:tabnext<CR>
nnoremap <PageDown> <esc>:tabprevious<CR>
inoremap <PageDown> <esc>:tabprevious<CR>

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
Plug 'ayu-theme/ayu-vim' " or other package manager
call plug#end()

" coloring
set termguicolors     " enable true colors support
let ayucolor="light"  " for light version of theme
colorscheme ayu
