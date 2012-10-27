set nocompatible

" Easily edit and reload the vimrc
nmap <silent> <leader>ev :e  $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set cursorline
hi CursorLine cterm=none ctermbg=darkgrey
