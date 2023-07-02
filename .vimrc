set nocompatible
filetype off

" Setup based on: https://realpython.com/vim-and-python-a-match-made-in-heaven/
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'   " Vundle
Plugin 'scrooloose/nerdtree'    " NERDTree
Plugin 'jistr/vim-nerdtree-tabs' " NERDTree tabs
Plugin 'tpope/vim-fugitive'     " git integration
Plugin 'kien/ctrlp.vim'         " search with Ctrl+P
" Plugin 'tmhedberg/SimpylFold'   " Folding
" Plugin 'Konfekt/FastFold'       " Fast folding
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ycm-core/YouCompleteMe' " Auto-complete
Plugin 'vim-syntastic/syntastic' " Syntax checking
Plugin 'nvie/vim-flake8'        " PEP8 checking
" Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}  " Status bar
Plugin 'sillybun/vim-repl'      " Python REPL
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-unimpaired'


call vundle#end()
filetype plugin indent on

let mapleader=" "
let maplocalleader="\\"

" Fix issues with typing [ and ] - recommended by
" https://github.com/tpope/vim-unimpaired
nmap < [
nmap > ]
omap < [
omap > ]
xmap < [
xmap > ]

" Open help in vertical split by default ?
autocmd FileType help wincmd L

" Override search highlighting to dark red
autocmd ColorScheme * :hi Search ctermbg=1 
colorscheme protto

set number
set hlsearch
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set encoding=utf-8
set scrolloff=7
set hidden
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

if !exists('g:lasttab')
    let g:lasttab = 1
endif

map <C-t><C-t> :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

" Navigation between splits
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

" Switching b/w buffers with fzf + fzf.vim
nnoremap <silent> <C-b> :Buffers<CR>
nnoremap <Leader>b :buffers<CR>:buffer<Space>

" Splits open below or right by default (rather than top and left)
set splitbelow
set splitright

" WSL yank support
" change this path according to your mount point:
let s:clip = '/mnt/c/Windows/System32/clip.exe' 
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif

" Automatically set paste mode in Vim when pasting in insert mode
" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
endfunction

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
" nnoremap <space> za

" Insert empty lines
nnoremap <Leader>o o<Esc>0"_D
nnoremap <Leader>O O<Esc>0"_D
" Clear highlighting
nnoremap <Leader><space> :noh<cr>
" Jumping to tags - my vim interprets ] as [...
nnoremap <Leader>) <C-]>
nnoremap <Leader>ú <C-O>

" Setting for REPL:
let g:repl_program = {
            \   'python': 'python',
            \   'default': 'bash',
            \   'r': 'R',
            \   'lua': 'lua',
            \   'vim': 'vim -e',
            \   }
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = '8.8'
let g:repl_output_copy_to_register = "t"
let g:repl_height = 20
nnoremap <leader>r :REPLToggle<Cr>
" nnoremap <leader>e :REPLSendSession<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
" Moving around in REPL
tnoremap <C-n> <C-w>N
tnoremap <ScrollWheelUp> <C-w>Nk
tnoremap <ScrollWheelDown> <C-w>Nj
inoremap <C-e> <Esc>:SendCurrentLine<Cr>i
nnoremap <C-e> :SendCurrentLine<Cr>
" inoremap <F5> <Esc>:SendCurrentLine<Cr>i

" Allow docstring previews
let g:SimpylFold_docstring_preview=1

" " Python indentation: PEP8
" au BufNewFile,BufRead *.py
"     \ set tabstop=4
"     \ set softtabstop=4
"     \ set shiftwidth=4
"     \ set textwidth=79
"     \ set expandtab
"     \ set autoindent
"     \ set fileformat=unix
 
let python_highlight_all=1

"autocomplete
let g:ycm_autoclose_preview_window_after_completion=1

let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

syntax on

autocmd StdinReadPre * let g:isReadingFromStdin = 1
autocmd VimEnter * if !argc() && !exists('g:isReadingFromStdin') | NERDTree | endif

if has('unnamedplus')
    set clipboard=unnamedplus
endif

if filereadable($HOME."/.local/.vimrc")
    source ~/.local/.vimrc
endif

