colorscheme dim
set number
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

if !exists('g:lasttab')
    let g:lasttab = 1
endif

map <C-t><C-t> :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

set splitbelow

autocmd StdinReadPre * let g:isReadingFromStdin = 1
autocmd VimEnter * if !argc() && !exists('g:isReadingFromStdin') | NERDTree | endif

if has('unnamedplus')
    set clipboard=unnamedplus
endif

if filereadable("~/.local/.vimrc")
    source ~/.local/.vimrc
endif

