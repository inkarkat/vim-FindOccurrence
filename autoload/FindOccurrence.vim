" FindOccurrence.vim: Extended mappings for :isearch, :ilist and :ijump.
"
" DEPENDENCIES:
"   - ingosearch.vim autoload script
"
" Copyright: (C) 2008-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" Source: http://vim.wikia.com/wiki/Search_visually
"
" REVISION	DATE		REMARKS
"	010	23-Aug-2012	Split off autoload script and documentation.
"	009	15-Jul-2010	BUG: Accidentally removed queried pattern from
"				the input history if the user cancels out of
"				selection.
"				ENH: Added [? ]? CTRL-W_? mappings that
"				reuse last queried pattern.
"				Now opening folds at the jump destination, even
"				though the original :ijump command and [ CTRL-I
"				mappings do not open the fold at the match.
"	008	05-Jan-2010	BUG: Didn't escape <cword> and didn't check
"				whether it actually must be enclosed in \<...\>.
"				Now using
"				ingosearch#LiteralTextToSearchPattern() for
"				that.
"	007	06-Oct-2009	Do not define mappings for select mode;
"				printable characters should start insert mode.
"	006	21-Mar-2009	Simplified handling of v:count.
"	005	16-Jan-2009	Now setting v:errmsg on errors.
"	004	07-Aug-2008	Complete refactoring; split operations into
"				separate functions.
"				Two new operations: jump-list and search-list,
"				which fall back on listing if the first op
"				didn't find anything.
"				Added {visual}]i.
"	003	06-Aug-2008	Adopted script; reformatted and refactored
"				argument handling.
"				Implemented ]n ]N ]<C-N> mappings for current
"				search result.
"				Implemented ]/ mapping for queried pattern.
"       002     08-Jul-2008     Added ] mappings that search only from cursor
"				position.
"	001	08-Jul-2008	file creation from Wiki page

function! s:EchoError()
    " After input(), the next :echo may be off-base. (Is this a Vim bug?)
    " A redraw fixes this.
    redraw

    echohl ErrorMsg
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away.
    let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
    echomsg v:errmsg
    echohl None
endfunction
function! s:DoSearch( isSilent )
    try
	execute s:range . 'isearch' . s:skipComment s:count s:pattern
    catch /^Vim\%((\a\+)\)\=:E389/ " Couldn't find pattern
	if ! a:isSilent
	    call s:EchoError()
	endif
	return 0
    catch /^Vim\%((\a\+)\)\=:E38[78]/
	call s:EchoError()
    endtry
    return 1
endfunction
function! s:DoSplit()
    try
	" Check that the destination exists before splitting the window.
	silent execute s:range . 'isearch' . s:skipComment s:count s:pattern
	split
	execute a:range . 'ijump' . s:skipComment s:count s:pattern
    catch /^Vim\%((\a\+)\)\=:E38[789]/
	call s:EchoError()
    endtry
endfunction
function! s:DoList()
    try
	execute s:range . 'ilist' . s:skipComment s:pattern
    catch /^Vim\%((\a\+)\)\=:E38[789]/
	call s:EchoError()
	return 0
    endtry

    let s:count = input('Go to: ')
    " Do not remember this selection, as it interferes with easy recall of
    " entered pattern (via <Up>).
    if ! empty(s:count)
	" Nothing is added to the input history if the user canceled with <Esc>.
	call histdel('input', -1)
    endif

    if s:count !~# '^[1-9]\d*$'
	" User canceled, there's no error message to show, so don't delay
	" visual reselection.
	let s:reselectionDelay = 0
	return 0
    endif

    return s:DoJump(0)
endfunction
function! s:DoJump( isSilent )
    try
	execute s:range . 'ijump' . s:skipComment s:count s:pattern
	let s:didJump = 1

	" For some unknown reason, the original :ijump command and [ CTRL-I
	" mappings do not open the fold at the match. I prefer to have the fold
	" opened.
	normal! zv

	return 1
    catch /^Vim\%((\a\+)\)\=:E389/ " Couldn't find pattern
	if a:isSilent
	    return 0
	else
	    call s:EchoError()
	endif
    catch /^Vim\%((\a\+)\)\=:E38[78]/
	call s:EchoError()
    endtry
    return 1
endfunction

function! FindOccurrence#Find( mode, operation, isEntireBuffer )
    let s:count = v:count1
    let s:skipComment = (v:count ? '!' : '')
    let s:range = (a:isEntireBuffer ? '' : '.+1,$')
    let s:didJump = 0
    let s:reselectionDelay = 1
    let l:selectionLength = 0

    if a:mode ==# 'n' " Normal mode, use word under cursor.
	let s:pattern = '/' . ingosearch#LiteralTextToSearchPattern(expand('<cword>'), 1, '') . '/'
    elseif a:mode ==# 'v' " Visual mode, use selection.
	execute 'normal! gvy'
	let s:pattern = '/\V' . substitute(escape(@@, '/\'), "\n", '\\n', 'g') . '/'
	let l:selectionLength = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
    elseif a:mode ==# '/' " Use current search result.
	let s:pattern = '/' . @/ . '/'
    elseif a:mode ==# '?' " Query for pattern.
	let l:pattern = input('/')
	if empty(l:pattern) | return | endif
	let s:lastPattern = l:pattern
	let s:pattern = '/' . l:pattern . '/'
    elseif a:mode ==# '?R' " Reuse last queried pattern.
	if ! exists('s:lastPattern')
	    " After input(), the next :echo may be off-base. (Is this a Vim bug?)
	    " A redraw fixes this.
	    redraw

	    let v:errmsg = 'No previous pattern, use [/ first'
	    echohl ErrorMsg
	    echomsg v:errmsg
	    echohl None

	    return
	endif
	let s:pattern = '/' . s:lastPattern . '/'
    else
	throw 'invalid mode "' . a:mode . '"'
    endif

    if a:operation ==# 'search'
	call s:DoSearch(0)
    elseif a:operation ==# 'search-list'
	if ! s:DoSearch(1)
	    call s:DoList()
	endif
    elseif a:operation ==# 'split'
	call s:DoSplit()
    elseif a:operation ==# 'list'
	call s:DoList()
    elseif a:operation ==# 'jump-list'
	if ! s:DoJump(1)
	    call s:DoList()
	endif
    elseif a:operation ==# 'jump'
	call s:DoJump(0)
    else
	throw 'invalid operation "' . a:operation . '"'
    endif

    if a:mode ==# 'v'
	if s:didJump
	    " We've jumped to a keyword, now select the keyword at the *new* position.
	    " Special case for single character visual [<Tab> (l:selectionLength == 0)
	    execute 'normal!' visualmode() . (l:selectionLength ? l:selectionLength . "\<Space>" : '')
	else
	    " We didn't jump, reselect the current keyword so that any operation
	    " can be repeated easily.

	    " If there was an error message, or an :iselect command, we must be
	    " careful not to immediately overwrite the desired output by
	    " re-entering visual mode.
	    if &cmdheight == 1
		if s:reselectionDelay
		    redraw
		    execute 'sleep' s:reselectionDelay
		endif
	    endif
	    normal! gv
	endif
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
