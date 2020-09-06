" Language:   Octo
" Maintainer: Jason LeBrun <jblebrun@gmail.com> 
" URL:        https://github.com/jblebrun/vim-octo
" LICENSE:    MIT

if exists("b:current_syntax")
 " finish
endif

setlocal autoindent

syn keyword register v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 va vb vc vd ve vf i delay buzzer key -key
hi def link register Type 


syn match sectionLabel ': [a-zA-Z0-9-]\+'
hi def link sectionLabel Label

syn keyword conditional if then else begin end loop again
syn keyword repeat loop again

syn match number '\<[0-9]\+'
syn match hexNumber '0x[a-fA-F0-9]\+'
hi def link hexNumber Number

syn match identifier '[a-zA-Z0-9-]+'

syn match operator '+=\|+\|-\|:=\|-=\|=-\|==\|!=\|>>=\|<<='

syn keyword function sprite save load clear return bcd jump jump0 random hex

syn match alias ':alias ' 
syn match const ':const '
syn match unpack ':unpack '
hi def link alias Preproc
hi def link const Preproc
hi def link unpack Preproc


syn region beginBlock start='begin' end='end' fold
syn region loopBlock start='loop' end='again' fold 

syn match comment '#.*$' 


let b:current_syntax = "octo"
