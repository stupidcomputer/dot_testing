" randomuser's vimrc
" vim-plug {{{
call plug#begin()
Plug 'honza/vim-snippets'
Plug 'sirver/ultisnips'
Plug 'tridactyl/vim-tridactyl'
Plug 'chrisbra/csv.vim'
Plug 'trapd00r/vimpoint'
Plug 'vimwiki/vimwiki'
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
set ts=2
set sw=2
set hlsearch
set incsearch
set ignorecase
set smartcase
set inccommand=nosplit
set nocompatible

colorscheme earth
" }}}

" shortcuts {{{
" toggle line numbers and listchars
nnoremap <Leader>ym :set number!<CR>:set list!<CR>
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
tnoremap <Esc> <C-\><C-n>
nnoremap <Leader>wl <C-w>\<
nnoremap <Leader>wr <C-w>\>
nnoremap <Leader>wd <C-w>-
nnoremap <Leader>wu <C-w>+

" }}}

" autocmds {{{
au Filetype python setl et ts=4 sw=4

function SwapExistsHandler()
	silent !vim-swap-handler "%:p"
	if v:shell_error == 0
		let v:swapchoice='o'
		return
	elseif v:shell_error == 1
		let v:swapchoice='o'
		echom "The file has been opened read-only, as there is not another vim instance editing this file."
	elseif v:shell_error == 127
		echom "The vim-swap-handler command doesn't exist."
	else
		echom "An unknown error occurred."
	endif
endfunction

autocmd SwapExists * call SwapExistsHandler()
au BufWrite bspwmrc !bspc wm -r
au BufWrite sxhkdrc !killall sxhkd -USR1
" }}}

" statusline {{{
set statusline=%f
set statusline+=\ 
set statusline+=%r%m%q%h
set statusline+=%=
set statusline+=%y\ 0x%02B\ %04l:%03c:%03p
" }}}

" titlebar {{{
let &titlestring='%{expand("%:p")}'
" }}}

" netrw {{{
let g:netrw_banner=0 
" }}}

" ultisnips {{{
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" }}}
