colorscheme dim
set number
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

