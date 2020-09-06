if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nolisp
setlocal autoindent

" Hook up the function below to be the handler for indenting lines when this
" file is loaded as the indent file for a particular filetype.
setlocal indentexpr=OctoIndent(v:lnum)

" Set up the indent keys to handle.
" If these keys are pressed while in insert mode the indentexpr will be run
" for the current line.
" When : is typed, we will reindent in case this is a new :directive line
" When } is typed we might be dedenting from a macro block
setlocal indentkeys+=:,0=}

if exists("*OctoIndent")
  "finish
endif

" Save compat settings to restore at the end.
" avoids spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

" Special patterns
let directivePat = '^\s*:'
let commentPat = '^\s*#'

" Dedent patterns
let endPat = '^\s*end\s*$'
let againPat = '^\s*again\s*$'
let macroClosePat = '.*}\s*$'
let dedent = '\('.g:endPat.'\|'.g:againPat.'\|'.g:macroClosePat.'\)'

" Indent patterns
let beginPat = '.*begin\s*$'
let loopPat = '^\s*loop\s*$'
let indent = '\('.g:beginPat.'\|'.g:loopPat.'\)'

" Find the previous code line, ignoring : directives and labels
" Will be either the first line, or a code line.
function! PrevCodeLine(lnum)
    let n = prevnonblank(a:lnum - 1)
    while n > 0
        let codeline = getline(n)
        if codeline !~ '^\(:\|#\|}\)'
            return n
        endif
        let n = prevnonblank(n-1)
    endwhile
    return n
endfunction

" Find the next line after this one that isn't a comment. 
" Will be either a directive, a code line, or the last line.
function! NextNonCommentLine(lnum) 
    let n = nextnonblank(a:lnum)
    while n < line('$')
        let line = getline(n)
        if line !~ g:commentPat
            return n
        endif
        let n = nextnonblank(n+1)
    endwhile
    return n
endfunction


" Determine indenting for a comment line
" Comments are indented:
" Same as previous comment
" Code indent if after a label
" 0 indent otherwise
function! OctoIndentComment(lnum)
    " Comments have affinity to what's after them.
    " So, we look for the next non comment line to decide
    " indent.
    let nextlinenum = NextNonCommentLine(a:lnum)

    " If we reach the end, we just assume it's a final file
    " comment, and don't indent it.
    if nextlinenum == line('$')
        return 0
    endif

    " If the comment is above a directive, those are always 
    " indented at 0, so also indent the comment at 0.
    let nextline = getline(nextlinenum)
    if nextline =~ g:directivePat
        return 0
    endif

    return OctoIndentFromPrevious(a:lnum)
endfunction

" Indent code or comment line based on the indentation of the previous non-comment,
" non-directive "code" line.
function! OctoIndentFromPrevious(lnum) 
    " Otherwise it's code. We use the previous code indentation.
    let prevcodelinenum = PrevCodeLine(a:lnum)
    
    " Unless there isn't a previous code line, we assume this is the 
    " first code or comment after
    " for the first line after a directive, and indent.
    if prevcodelinenum == 0
        return shiftwidth()
    endif
    
    let previndent = indent(prevcodelinenum)
    let prevcodeline = getline(prevcodelinenum)

    " Previous line triggers an indent, so bump up 1 level.
    if prevcodeline =~ g:indent
        return previndent + shiftwidth()
    endif

    " Otherwise just use previous code indentation
    return previndent
endfunction

" Top-level indent handling function
function! OctoIndent(lnum) abort
    " It's the first line, never indented.
    if a:lnum == 1
        return 0
    endif

    let linetext = getline(a:lnum) 

    " Directive lines (begining with :) are always unindented
    if linetext =~ g:directivePat
        return 0
    endif

    " Handle comments
    if linetext =~ g:commentPat
        return OctoIndentComment(a:lnum)
    endif

    " Dedent after `end`, `again`, `}`
    if linetext =~ g:dedent 
        return indent(PrevCodeLine(a:lnum))- shiftwidth()
    endif
    
    return OctoIndentFromPrevious(a:lnum)
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save
