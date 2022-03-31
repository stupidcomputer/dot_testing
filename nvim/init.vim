" randomuser's vimrc

nnoremap ; :
nnoremap : ;
let mapleader = " "

" defined settings
set number
set encoding=utf8
set lcs=tab:->,trail:_,eol:^
set clipboard=unnamedplus
colorscheme earth

" shortcuts
nnoremap <Leader>ym :set number!<CR>:set list!<CR>

nnoremap <Leader>w :!curl -s wttr.in/?0T<CR>
nnoremap <Leader>rr :source ~/.config/nvim/init.vim<CR>
nnoremap <Leader>re :edit ~/.config/nvim/init.vim<CR>
nnoremap <Leader>m :make<CR>

inoremap jk <esc>
inoremap <esc> <esc>:echo "use jk instead!"<CR>2gsi

" autocmds
au Filetype python setl et ts=4 sw=4

" statusline

set statusline=%f
set statusline+=\ 
set statusline+=%r%m%q
set statusline+=%=
set statusline+=%y\ %B\ %l:%c:%p
