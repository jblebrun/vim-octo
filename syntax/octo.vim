" Language:   Octo
" Maintainer: Jason LeBrun <jblebrun@gmail.com> 
" URL:        https://github.com/jblebrun/vim-octo
" LICENSE:    MIT

if exists("b:current_syntax")
  finish
endif

setlocal autoindent

syn keyword register v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 va vb vc vd ve vf
hi def link register Constant 

syn keyword conditional if then else begin end loop again

syn match number '[0-9]\+'
syn match hexNumber '0x[a-fA-F0-9]\+'
hi def link hexNumber Number


syn match operator '+\|-\|:=\|-=\|=-\|+=\|=='

syn keyword function sprite save load

syn match alias ':alias [a-zA-Z0-9]\+ ' 
syn match const ':const '
hi def link alias Macro
hi def link const Macro


syn match sectionLabel ': [a-z]\+'
hi def link sectionLabel Label

syn region beginBlock start='begin' end='end' fold
syn region loopBlock start='loop' end='again' fold 

syn match comment '#.*$' contains=commentText


let b:current_syntax = "octo"
