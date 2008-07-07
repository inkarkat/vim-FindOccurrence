" source: http://vim.wikia.com/wiki/Search_visually

" Avoid installing twice. 
if exists('g:loaded_FindOccurrence')
    finish
endif
let g:loaded_FindOccurrence = 1 

" To display all the lines where the word under the cursor occurs, simply do in
" Normal mode: [I. This can be useful to find a count of lines of search
" occurrences. Each line displayed is numbered. 
" In order to jump to the <n>th line of occurrence, do: <n>[I; this is similar
" to <n>[i, which displays the <n>th line of occurrence. 
" The function and mappings below work in visual mode too, so that the search
" will be done for the visual highlight. 
" In addition, [I without <n> asks for the occurrence number to jump to. 
" The [ mappings start at the beginning of the file, the ] mappings at the
" current cursor position. Commented lines are not ignored, as with <n>[i; [i
" skips commented lines. 
nmap <silent>[I :<C-u>cal OSearch("n%")<CR>
nmap <silent>]I :<C-u>cal OSearch("n.")<CR>
vmap <silent>[I :<C-u>cal OSearch("v%")<CR>
vmap <silent>]I :<C-u>cal OSearch("v.")<CR>

function! OSearch(action)
  let c = v:count
  let range = (a:action[1] == '%' ? '' : '.+1,$')
  if a:action[0] == "n"
    let s = "/\\<".expand("<cword>")."\\>/"
  elseif a:action[0] == "v"
    execute "normal! gvy"
    let s = "/\\V".substitute(escape(@@, "/\\"), "\n", "\\\\n", "g")."/"
    let diff = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
  endif
  if empty(c)
    try
      execute range."ilist! ".s
    catch
      if a:action[0] == "v"
        normal! gv
      endif
      return ""
    endtry
    let c = input("Go to: ")
    if c !~ "^[1-9]\\d*$"
      if a:action[0] == "v"
        normal! gv
      endif
      return ""
    endif
  endif
  let v:errmsg = ""
  silent! execute range."ijump! ".c." ".s
  if v:errmsg == ""
    if a:action[0] == "v"
      " Initial version
      " execute "normal! ".visualmode().diff."\<Space>"
      " Bug fixfor single character visual [<Tab>:
      if diff
        execute "normal! ".visualmode().diff."\<Space>"
      else
        execute "normal! ".visualmode()
      endif
    endif
  elseif a:action[0] == "v"
    normal! gv
  endif
endfunction

