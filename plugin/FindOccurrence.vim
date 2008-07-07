" source: http://vim.wikia.com/wiki/Search_visually

" Avoid installing twice. 
if exists('g:loaded_FindOccurrence')
    finish
endif
let g:loaded_FindOccurrence = 1 

" To display all the lines where the word under the cursor occurs, simply do in Normal mode: [I
" This can be useful to find a count of lines of search occurrences. Each line
" displayed is numbered. 
" In order to jump to the <n>th line of occurrence, do: <n>[<Tab>
" This means type in the <n>umber first, hit '[', and then the Tab button. If
" <n> is not typed, the jump defaults to the line where the first (uncommented)
" word appears.
" The function and mappings below allow for [I and <n>[<Tab> to work in visual
" mode too, so that the search will be done for the visual highlight. In
" addition, [I asks for the occurrence number to jump to. 
nmap <silent>[I :<C-u>cal OSearch("nl")<CR>
nmap <silent>[<Tab> :<C-u>cal OSearch("nj")<CR>
vmap <silent>[I :<C-u>cal OSearch("vl")<CR>
vmap <silent>[<Tab> :<C-u>cal OSearch("vj")<CR>

function! OSearch(action)
  let c = v:count1
  if a:action[0] == "n"
    let s = "/\\<".expand("<cword>")."\\>/"
  elseif a:action[0] == "v"
    execute "normal! gvy"
    let s = "/\\V".substitute(escape(@@, "/\\"), "\n", "\\\\n", "g")."/"
    let diff = (line2byte("'>") + col("'>")) - (line2byte("'<") + col("'<"))
  endif
  if a:action[1] == "l"
    try
      execute "ilist! ".s
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
  silent! execute "ijump! ".c." ".s
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

