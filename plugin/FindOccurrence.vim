" FindOccurrence.vim: Extended mappings for :isearch, :ilist and :ijump. 
"
" DESCRIPTION:
"   This script adds the following features to the default VIM mappings for
"   :isearch, :ilist and :ijump:
"   - ]I et al. not only list the occurrences, but ask for the occurrence number
"     to jump to. 
"   - ]I et al. also work in visual mode, searching for the selection instead of
"     the keyword under cursor. 
"   - New ]n ]N ]<C-N> <C-W>n <C-W><C-N> mappings that operate on the current
"     search results. 
"   - New ]/ <C-W>/ mappings that query and then operate on a pattern. 
"
" USAGE:
"   - The [ and <C-W> mappings start at the beginning of the file, the ]
"     mappings at the line after the cursor. 
"   - Without a [count], commented lines are ignored. 
"   - x just echoes the occurrence, X prints a list of the occurrences and asks
"     for the occurrence number to jump to, <C-X> directly jumps to the
"     occurrence, <C-W>x and <C-W><C-X> split the window and jump to the
"     occurrence.  
"   - i I <Tab> <C-W>i <C-W><Tab> for keyword under cursor. 
"   - d D <C-D> <C-W>d <C-W><C-D> for macro definition under cursor. 
"   - n N <C-N> <C-W>n <C-W><C-N> for current search result. 
"   - / <C-W>/                    for queried pattern. 
"
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2008 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" Source: http://vim.wikia.com/wiki/Search_visually
"
" REVISION	DATE		REMARKS 
"	003	06-Aug-2008	Adopted script; reformatted and refactored
"				argument handling. 
"				Implemented ]n ]N ]<C-N> mappings for current
"				search result. 
"				Implemented ]/ mapping for queried pattern. 
"       002     08-Jul-2008     Added ] mappings that search only from cursor
"				position. 
"	001	08-Jul-2008	file creation from Wiki page

" Avoid installing twice. 
if exists('g:loaded_FindOccurrence') || (v:version < 700)
    finish
endif
let g:loaded_FindOccurrence = 1 

function! s:EchoError()
    " After input(), the next :echo may be off-base. (Is this a VIM bug?)
    " A redraw fixes this. 
    redraw

    echohl ErrorMsg
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away. 
    echomsg substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
    echohl NONE
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
	return
    endtry

    let s:count = input('Go to: ')
    " Do not remember this selection, as it interferes with easy recall of
    " entered pattern (via <Up>). 
    call histdel('input', -1)
    if s:count !~ '^[1-9]\d*$'
	return
    endif

    call s:DoJump(0)
endfunction
function! s:DoJump( isSilent )
    try
	execute s:range . 'ijump' . s:skipComment s:count s:pattern
	let s:didJump = 1
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

function! s:FindOccurrence( mode, operation, isEntireBuffer )
    let s:count = v:count1
    let s:skipComment = (empty(v:count) ? '' : '!')
    let s:range = (a:isEntireBuffer ? '' : '.+1,$')
    let s:didJump = 0
    let l:selectionLength = 0

    if a:mode == 'n' " Normal mode, use word under cursor. 
	let s:pattern = '/\<' . expand('<cword>') . '\>/'
    elseif a:mode == 'v' " Visual mode, use selection. 
	execute 'normal! gvy'
	let s:pattern = '/\V' . substitute(escape(@@, '/\'), "\n", '\\n', 'g') . '/'
	let l:selectionLength = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
    elseif a:mode == '/' " Use current search result. 
	let s:pattern = '/' . @/ . '/'
    elseif a:mode == '?' " Query for pattern. 
	let l:pattern = input('/')
	if l:pattern == ''
	    return
	endif
	let s:pattern = '/' . l:pattern . '/'
    else
	throw 'invalid mode "' a:mode '"'
    endif

    if a:operation == 'search'
	call s:DoSearch(0)
    elseif a:operation == 'search-list'
	if ! s:DoSearch(1)
	    call s:DoList()
	endif
    elseif a:operation == 'split'
	call s:DoSplit()
    elseif a:operation == 'list'
	call s:DoList()
    elseif a:operation == 'jump-list'
	if ! s:DoJump(1)
	    call s:DoList()
	endif
    elseif a:operation == 'jump'
	call s:DoJump(0)
    endif

    if a:mode == 'v'
	if s:didJump
	    " Special case for single character visual [<Tab> (l:selectionLength == 0)
	    execute 'normal!' visualmode() . (l:selectionLength ? l:selectionLength . "\<Space>" : '')
	else
	    redraw
	    sleep 1
	    normal! gv
	endif
    endif
endfunction

vnoremap <silent> [i         :<C-u>call <SID>FindOccurrence('v', 'search', 1)<CR>
vnoremap <silent> ]i         :<C-u>call <SID>FindOccurrence('v', 'search', 0)<CR>
nnoremap <silent> [I         :<C-u>call <SID>FindOccurrence('n', 'list', 1)<CR>
vnoremap <silent> [I         :<C-u>call <SID>FindOccurrence('v', 'list', 1)<CR>
nnoremap <silent> ]I         :<C-u>call <SID>FindOccurrence('n', 'list', 0)<CR>
vnoremap <silent> ]I         :<C-u>call <SID>FindOccurrence('v', 'list', 0)<CR>
nnoremap <silent> [<Tab>     :<C-u>call <SID>FindOccurrence('n', 'jump', 1)<CR>
vnoremap <silent> [<Tab>     :<C-u>call <SID>FindOccurrence('v', 'jump', 1)<CR>
nnoremap <silent> ]<Tab>     :<C-u>call <SID>FindOccurrence('n', 'jump', 0)<CR>
vnoremap <silent> ]<Tab>     :<C-u>call <SID>FindOccurrence('v', 'jump', 0)<CR>

nnoremap <silent> [n         :<C-u>call <SID>FindOccurrence('/', 'search', 1)<CR>
nnoremap <silent> ]n         :<C-u>call <SID>FindOccurrence('/', 'search', 0)<CR>
" Disabled because they would overwrite default commands. 
"nnoremap <silent> <C-W>n     :<C-u>call <SID>FindOccurrence('/', 'split', 1)<CR>
"nnoremap <silent> <C-W><C-N> :<C-u>call <SID>FindOccurrence('/', 'split', 1)<CR>
nnoremap <silent> [N         :<C-u>call <SID>FindOccurrence('/', 'list', 1)<CR>
nnoremap <silent> ]N         :<C-u>call <SID>FindOccurrence('/', 'list', 0)<CR>
nnoremap <silent> [<C-N>     :<C-u>call <SID>FindOccurrence('/', 'jump', 1)<CR>
nnoremap <silent> ]<C-N>     :<C-u>call <SID>FindOccurrence('/', 'jump', 0)<CR>

" These eclipse [/ and ]/ motions, but you can still use [* and ]*. 
nnoremap <silent> <C-W>/     :<C-u>call <SID>FindOccurrence('?', 'split', 1)<CR>
nnoremap <silent> [/         :<C-u>call <SID>FindOccurrence('?', (v:count==0 ? 'list' : 'jump-list'), 1)<CR>
nnoremap <silent> ]/         :<C-u>call <SID>FindOccurrence('?', (v:count==0 ? 'list' : 'jump-list'), 0)<CR>

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
