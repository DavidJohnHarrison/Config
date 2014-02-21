set nocompatible

" Easily edit and reload the vimrc
nmap <silent> <leader>ev :e  $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set cursorline
hi CursorLine cterm=none ctermbg=darkgrey

syntax on

" Navigate by display lines
noremap <buffer> <silent> k gk
noremap <buffer> <silent> j gj
noremap <buffer> <silent> 0 g0
noremap <buffer> <silent> $ g$

" Tabbing
set tabstop=4
set shiftwidth=6


" Visual Aids for Tabs and Whitespace
set list listchars=tab:\|\ 
highlight SpecialKey ctermfg=darkgrey
highlight TrailingWhitespace ctermbg=red guibg=red
highlight NotableCharacters ctermbg=green guibg=green
match TrailingWhitespace /\s\+\%#\@<!$/

" Extensions
execute pathogen#infect()

