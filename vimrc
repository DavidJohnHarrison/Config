set nocompatible
filetype plugin on

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


" Margins
" Warn of characters over 80 for coursework and 120 for real development
highlight Over80CharsLong ctermbg=yellow
highlight Over120CharsLong ctermbg=red
au BufWinEnter * let w:m2=matchadd('Over80CharsLong', '\%>80v.\+', -1)
au BufWinEnter * let w:m2=matchadd('Over120CharsLong', '\%>120v.\+', -1)

" Extensions
execute pathogen#infect()

" Automatically make on write
function RunMake()
	let currentDirectory = "./"
	let makefile = "Makefile"
	let gitDirectory = ".git"
	let depth = 2
	let continue = 1
	while continue == 1
		if filereadable(currentDirectory . makefile)
			cd `=currentDirectory`
			silent !make > /dev/null
			let continue = 0
			cd -
		elseif isdirectory(currentDirectory . gitDirectory) || depth > 3
			let continue = 0
		else
			let depth += 1
			let currentDirectory = "../" . currentDirectory
		endif
	endwhile
endfunction

autocmd BufWritePost *.tex call RunMake()
