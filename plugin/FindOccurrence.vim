" FindOccurrence.vim: Extended mappings for :isearch, :ilist and :ijump. 
"
" DESCRIPTION:
"   This script adds the following features to the default VIM mappings for
"   :isearch, :ilist and :ijump:
"   - ]I et al. not only list the occurrences, but ask for the occurrence number
"     to jump to. 
"   - ]I et al. also work in visual mode, searching for the selection instead of
"     the keyword under cursor. 
"   - New ]n/]N/]<C-N>/<C-W>n/<C-W><C-N> mappings that operate on the current
"     search results. 
"
" USAGE:
"   - The [ and <C-W> mappings start at the beginning of the file, the ]
"     mappings at the line after the cursor. 
"   - Without a [count], commented lines are ignored. 
"   - x just echoes the occurrence, X prints a list of the occurrences and asks
"     for the occurrence number to jump to, <C-X> directly jumps to the
"     occurrence, <C-W>x and <C-W><C-X> split the window and jump to the
"     occurrence.  
"   - i/I/<Tab>/<C-W>i/<C-W><Tab> for keyword under cursor. 
"   - d/D/<C-D>/<C-W>d/<C-W><C-D> for macro definition under cursor. 
"   - n/N/<C-N>/<C-W>n/<C-W><C-N> for current search result. 
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
"				Implemented ]n/]N/]<C-N> mappings for current
"				search result. 
"       002     08-Jul-2008     Added ] mappings that search only from cursor
"				position. 
"	001	08-Jul-2008	file creation from Wiki page

" Avoid installing twice. 
if exists('g:loaded_FindOccurrence')
    finish
endif
let g:loaded_FindOccurrence = 1 

function! s:EchoError()
    echohl ErrorMsg
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away. 
    echomsg substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
    echohl NONE
endfunction
function! s:FindOccurrence( mode, operation, isEntireBuffer )
    let c = v:count1
    let skipComment = (empty(v:count) ? '' : '!')
    let range = (a:isEntireBuffer ? '' : '.+1,$')

    if a:mode == 'n'
	let s = '/\<' . expand('<cword>') . '\>/'
    elseif a:mode == 'v'
	execute 'normal! gvy'
	let s = '/\V' . substitute(escape(@@, '/\'), "\n", '\\n', 'g') . '/'
	let diff = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
    elseif a:mode == '/'
	let s = '/' . @/ . '/'
    else
	throw 'invalid mode "' a:mode '"'
    endif

    if a:operation == 'search'
	try
	    execute range . 'isearch' . skipComment c s
	catch /^Vim\%((\a\+)\)\=:E/
	    call s:EchoError()
	endtry
	return
    elseif a:operation == 'split'
	try
	    " Check that the destination exists before splitting the window. 
	    silent execute range . 'isearch' . skipComment c s
	    split
	    execute range . 'ijump' . skipComment c s
	catch /^Vim\%((\a\+)\)\=:E/
	    call s:EchoError()
	endtry
	return
    elseif a:operation == 'list'
	try
	    execute range . 'ilist' . skipComment s
	catch /^Vim\%((\a\+)\)\=:E/
	    call s:EchoError()

	    if a:mode == 'v'
		normal! gv
	    endif
	    return
	endtry
	let c = input('Go to: ')
	if c !~ '^[1-9]\d*$'
	    if a:mode == 'v'
		normal! gv
	    endif
	    return
	endif
    endif
    let v:errmsg = ''
    silent! execute range . 'ijump' . skipComment c s
    if v:errmsg == ''
	if a:mode == 'v'
	    " Special case for single character visual [<Tab> (diff == 0)
	    execute 'normal!' visualmode() . (diff ? diff . "\<Space>" : '')
	endif
    elseif a:mode == 'v'
	normal! gv
    endif
endfunction

nnoremap <silent>[I         :<C-u>call <SID>FindOccurrence('n', 'list', 1)<CR>
vnoremap <silent>[I         :<C-u>call <SID>FindOccurrence('v', 'list', 1)<CR>
nnoremap <silent>]I         :<C-u>call <SID>FindOccurrence('n', 'list', 0)<CR>
vnoremap <silent>]I         :<C-u>call <SID>FindOccurrence('v', 'list', 0)<CR>
nnoremap <silent>[<Tab>     :<C-u>call <SID>FindOccurrence('n', 'jump', 1)<CR>
vnoremap <silent>[<Tab>     :<C-u>call <SID>FindOccurrence('v', 'jump', 1)<CR>
nnoremap <silent>]<Tab>     :<C-u>call <SID>FindOccurrence('n', 'jump', 0)<CR>
vnoremap <silent>]<Tab>     :<C-u>call <SID>FindOccurrence('v', 'jump', 0)<CR>

nnoremap <silent>[n         :<C-u>call <SID>FindOccurrence('/', 'search', 1)<CR>
nnoremap <silent>]n         :<C-u>call <SID>FindOccurrence('/', 'search', 0)<CR>
" Disabled due to conflict with ingowindowmappings.vim. 
"nnoremap <silent><C-W>n     :<C-u>call <SID>FindOccurrence('/', 'split', 1)<CR>
"nnoremap <silent><C-W><C-N> :<C-u>call <SID>FindOccurrence('/', 'split', 1)<CR>
nnoremap <silent>[N         :<C-u>call <SID>FindOccurrence('/', 'list', 1)<CR>
nnoremap <silent>]N         :<C-u>call <SID>FindOccurrence('/', 'list', 0)<CR>
nnoremap <silent>[<C-N>     :<C-u>call <SID>FindOccurrence('/', 'jump', 1)<CR>
nnoremap <silent>]<C-N>     :<C-u>call <SID>FindOccurrence('/', 'jump', 0)<CR>

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
