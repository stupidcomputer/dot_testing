set background=dark
highlight clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name = "earth"

hi Normal	ctermbg=black ctermfg=NONE cterm=NONE
hi Comment	ctermbg=NONE ctermfg=darkblue cterm=NONE
hi Operator	ctermbg=NONE ctermfg=green cterm=NONE
hi Statement	ctermbg=NONE ctermfg=green cterm=NONE
hi link Keyword Operator
hi Label	ctermbg=NONE ctermfg=darkyellow cterm=NONE
hi link Function Label
hi link Repeat Label
hi link Conditional Label
hi link Exception Label
hi Identifier	ctermbg=NONE ctermfg=blue cterm=NONE
hi link Constant Identifier

hi PreProc	ctermbg=NONE ctermfg=darkblue cterm=NONE
hi link Include PreProc
hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc

hi Type	ctermbg=NONE ctermfg=blue cterm=NONE

hi Constant	ctermbg=NONE ctermfg=blue cterm=NONE

hi Error	ctermbg=darkred ctermfg=white cterm=NONE
hi Todo	ctermbg=darkyellow ctermfg=black cterm=NONE

hi Search ctermbg=NONE ctermfg=red cterm=NONE
hi LineNr ctermbg=black ctermfg=gray
hi Pmenu ctermbg=blue ctermfg=black
hi PmenuSel ctermbg=green ctermfg=black

hi VertSplit ctermbg=NONE ctermfg=white cterm=NONE

hi StatusLine ctermbg=black ctermfg=white cterm=NONE gui=NONE
hi StatusLineNC ctermbg=white ctermfg=black cterm=NONE gui=NONE

hi SpellBad ctermbg=NONE ctermfg=red cterm=NONE
hi SpellCap ctermbg=NONE ctermfg=12 cterm=NONE
hi SpellRare ctermbg=NONE ctermfg=13 cterm=NONE
hi SpellLocal ctermbg=NONE ctermfg=14 cterm=NONE
