" randomuser's vimrc

" sacred nnoremaps {{{
nnoremap ; :
nnoremap : ;
" }}}
" misc settings {{{
let mapleader=" "
set nocompatible wildmenu path+=**
syntax enable
filetype plugin on
if has('nvim')
  nmap <Leader>s ;source ~/.config/nvim/init.vim<CR>
else
  nmap <Leader>s ;source ~/.vimrc<CR>
endif
" }}}
" displays {{{
set number
set numberwidth=3
set statusline=%#PmenuSel#%y%m\ %.20f%<%=b%02n:l%03l:c%03c
" }}}
" netrw {{{
let g:netrw_banner=0
let g:netrw_liststyle=3
let g:netrw_winsize=15
let g:netrw_browse_split=1
nmap <Leader>oe :Vexplore<CR>
" }}}
" file opening {{{
nmap <Leader>ob ;edit ~/.bashrc<CR>
if has('nvim')
  nmap <Leader>ov ;edit ~/.config/nvim/init.vim<CR>
else
  nmap <Leader>ov ;edit ~/.vimrc<CR>
endif
nmap <Leader>ow ;edit ~/.config/vimb/config<CR>
nmap <Leader>os ;edit ~/.config/vimb/style.css<CR>
nmap <Leader>oz ;edit ~/.config/zathura/zathurarc<CR>
nmap <Leader>ot ;edit ~/.config/bspwm/bspwmrc<CR>
nmap <Leader>ok ;edit ~/.config/sxhkd/sxhkdrc<CR>

" helpfiles
nmap <Leader>he ;help 
" }}}
" file execution {{{
" makefiles {{{
nmap <Leader>mm ;!make<CR>
nmap <Leader>mc ;!make clean<CR>
nmap <Leader>mf ;!make "%"<CR>
nmap <Leader>mi ;!make install<CR>
" }}}
" shell script {{{
nmap <Leader>ss ;!sh "%"<CR>
nmap <Leader>sb ;!bash "%"<CR>
nmap <Leader>sz ;!zsh "%"<CR>
" }}}
" }}}
" tab & fold settings {{{

" hacky exemption thing
" make sure to not populate this too much
let exemptions = ["gophermap", "Makefile"]
let tmp = 0
for exemption in exemptions
  " does this match the current file name
  if expand("%:t") != exemption
    let tmp = tmp + 1
  endif
endfor
" does the file match?
if tmp != 0
  set expandtab
  set tabstop=2
  set shiftwidth=2
  retab
endif
set list
set listchars=eol:`,tab:>-,trail:~,extends:<,precedes:>
set foldmethod=marker
" }}}
" buffers & tabs {{{
nmap <Leader>bn ;bn<CR>
nmap <Leader>bp ;bp<CR>
nmap <Leader>bc ;clo<CR>

nmap <Leader>tn ;tabnext<CR>
nmap <Leader>tp ;tabprev<CR>
nmap <Leader>t1 ;tabfirst<CR>
nmap <Leader>tc ;tabc<CR>
nmap <Leader>tt ;tabnew<CR>
" }}}
" information {{{
nmap <Leader>iw ;!curl -s http://wttr.in/?0qT<CR>
nmap <Leader>id ;!date<CR>

nmap <Leader>se ;setlocal spell spelllang=en_us<CR>
nmap <Leader>sd ;setlocal nospell<CR>
" }}}
