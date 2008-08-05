" TODO: summary
"
" DESCRIPTION:
" USAGE:
"   To display all the uncommented lines where the word under the cursor occurs,
"   simply do in Normal mode: [I. To include commented lines, prepend any
"   <n>umber: 1[I. 
"   This can be useful to find a count of lines of search occurrences. Each line
"   displayed is numbered. 
"   In order to jump to the <n>th line of occurrence, do: <n>[<Tab>
"   This means type in the <n>umber first, hit '[', and then the Tab button. If
"   <n> is not typed, the jump defaults to the line where the first
"   (uncommented) word appears. If <n> is typed, commented lines are not
"   ignored. The function and mappings below allow for [I and <n>[<Tab> to work
"   in visual mode too, so that the search will be done for the visual
"   highlight. In addition, [I asks for the occurrence number to jump to. The [
"   mappings start at the beginning of the file, the ] mappings at the current
"   cursor position. 
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
"       002     08-Jul-2008     Added ] mappings that search only from cursor
"				position. 
"	001	08-Jul-2008	file creation from Wiki page

" Avoid installing twice. 
if exists('g:loaded_FindOccurrence')
    finish
endif
let g:loaded_FindOccurrence = 1 

function! s:FindOccurrence( mode, isList, isEntireBuffer )
    let c = v:count1
    let skipComment = (empty(v:count) ? '' : '!')
    let range = (a:isEntireBuffer ? '' : '.+1,$')
    if a:mode == 'n'
	let s = '/\<'.expand('<cword>').'\>/'
    elseif a:mode == 'v'
	execute 'normal! gvy'
	let s = '/\V'.substitute(escape(@@, '/\'), "\n", '\\n', 'g').'/'
	let diff = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
    endif
    if a:isList
	try
	    execute range . 'ilist' . skipComment s
	catch
	    if a:mode == 'v'
		normal! gv
	    endif
	    return ''
	endtry
	let c = input('Go to: ')
	if c !~ '^[1-9]\d*$'
	    if a:mode == 'v'
		normal! gv
	    endif
	    return ''
	endif
    endif
    let v:errmsg = ''
    silent! execute range . 'ijump' . skipComment c s
    if v:errmsg == ''
	if a:mode == 'v'
	    " Initial version
	    " execute "normal!" visualmode().diff."\<Space>"
	    " Bug fixfor single character visual [<Tab>:
	    if diff
		execute 'normal!' visualmode() . diff . "\<Space>"
	    else
		execute 'normal!' visualmode()
	    endif
	endif
    elseif a:mode == 'v'
	normal! gv
    endif
endfunction

nnoremap <silent>[I     :<C-u>call <SID>FindOccurrence('n', 1, 1)<CR>
nnoremap <silent>]I     :<C-u>call <SID>FindOccurrence('n', 1, 0)<CR>
nnoremap <silent>[<Tab> :<C-u>call <SID>FindOccurrence('n', 0, 1)<CR>
nnoremap <silent>]<Tab> :<C-u>call <SID>FindOccurrence('n', 0, 0)<CR>
vnoremap <silent>[I     :<C-u>call <SID>FindOccurrence('v', 1, 1)<CR>
vnoremap <silent>]I     :<C-u>call <SID>FindOccurrence('v', 1, 0)<CR>
vnoremap <silent>[<Tab> :<C-u>call <SID>FindOccurrence('v', 0, 1)<CR>
vnoremap <silent>]<Tab> :<C-u>call <SID>FindOccurrence('v', 0, 0)<CR>

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
