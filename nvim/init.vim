" randomuser's vimrc
" vim-plug {{{
call plug#begin()
Plug 'honza/vim-snippets'
Plug 'sirver/ultisnips'
Plug 'tridactyl/vim-tridactyl'
Plug 'chrisbra/csv.vim'
Plug 'trapd00r/vimpoint'
cal plug#end()
" }}}

" misc {{{
nnoremap ; :
nnoremap : ;
let mapleader = " "
set nocompatible
" }}}

" defined settings {{{
set number
set foldmethod=marker
set encoding=utf8
set list
set lcs=tab:->,trail:_,eol:^
set clipboard=unnamedplus
set spell
set spelllang=en_us
set title
colorscheme earth
" }}}

" shortcuts {{{
" toggle line numbers and listchars
nnoremap <Leader>ym :set number!<CR>:set list!<CR>
" weather
nnoremap <Leader>w :!curl -s wttr.in/?0T<CR>
" vimrc thing
nnoremap <Leader>rr :source ~/.config/nvim/init.vim<CR>
nnoremap <Leader>re :edit ~/.config/nvim/init.vim<CR>
" show the file explorer
nnoremap <Leader>fs :Lexplore<CR>
" show the shortcuts in the vimrc
nnoremap <Leader>ke :e ~/.config/nvim/init.vim <CR>ggzR/shortcuts<CR>z<CR>
" jk to escape insert mode
inoremap jk <esc>
inoremap <esc> <esc>:echo "use jk instead!"<CR>2gsi
" go back to the previous error, then correct
inoremap <C-d> <c-g>u<Esc>[s1z=`]a<c-g>u
inoremap <C-s> <Esc>zgi
nnoremap <C-s> zg

" }}}

" autocmds {{{
au Filetype python setl et ts=4 sw=4
" }}}

" statusline {{{
set statusline=%f
set statusline+=\ 
set statusline+=%r%m%q
set statusline+=%=
set statusline+=%y\ %B\ %l:%c:%p
" }}}

" netrw {{{
let g:netrw_banner=0 
" }}}

" ultisnips {{{
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" }}}
