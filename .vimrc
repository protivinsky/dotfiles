colorscheme dim
set number
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

if !exists('g:lasttab')
    let g:lasttab = 1
endif

map <C-t><C-t> :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

set splitbelow

