" Set the 'cpoptions' option to its Vim default value and restore it later.
" This is to enable line-continuation within this script.
" Refer to :help use-cpo-save.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" Aligning  {{{

" Ask user for a character and align the 1st of that character in every line
" from current line to the end by inserting spaces. In visual mode, do the
" same thing only for the selected lines.
nmap <leader>ali <Plug>AligncharacterDoit
xmap <leader>ali <Plug>AligncharacterDoit
nnoremap <script> <Plug>AligncharacterDoit <SID>Doit
xnoremap <script> <Plug>AligncharacterDoit <SID>Doit
nnoremap <SID>Doit :call <SID>Doit(mode())<CR>
xnoremap <SID>Doit :<C-U>call <SID>Doit(visualmode())<CR>

function! s:Doit(mode, ...) " {{{

  let [l:startLN, l:endLN] = a:mode ==? visualmode()
    \ ? [line("'<"), line("'>")]
    \ : [line("."), line("$")]

  if exists('a:1')
    let l:aChar = a:1
  else
    echo 'Align which character? '
    let l:aChar = nr2char(getchar())
  endif

  " Find the align position while preserving one preceding space if any
  " exists.
  let l:lnum = l:startLN
  let l:aliIdx = 0
  while l:lnum <= l:endLN

    " A multibyte character such as a Chinese character, when the option
    " 'encoding' is set to utf-8, needs 2 to 4 bytes to store in memory which
    " is not usually equal to its display width, namely 2. Thus the aligning
    " operation will insert a wrong number of, in fact less, spaces if some
    " Chinese characters precede the aligned character.
    " To insure the function match count such a character also as 2 indices
    " (byte offset), one can set 'encoding' to cp936 or gbk before opening
    " the file and performing alignment.
    " Reference: http://littlewhite.us/archives/387

    " Update: No trouble with multibyte characters now!
    " strdisplaywidth(), which exactly, as the name suggests, deals with
    " display width, has taken over responsibility from match().

    let l:lstr = getline(l:lnum)
    let l:matchIdx = match(l:lstr, ' \?\zs *\V' . l:aChar)
    if l:matchIdx != -1
      let l:leadingStr = strpart(l:lstr, 0, l:matchIdx)
      let l:preDisplayWidth = strdisplaywidth(l:leadingStr)
      if l:aliIdx < l:preDisplayWidth
        let l:aliIdx = l:preDisplayWidth
      endif
    endif
    let l:lnum += 1
  endwhile

  let l:lnum = l:startLN
  while l:lnum <= l:endLN
    let l:lstr = getline(l:lnum)
    " l:aCharIdx is where the aligned character exactly is.
    let l:aCharIdx = match(l:lstr, '\V' . l:aChar)
    if l:aCharIdx != -1
      let l:matchIdx = match(l:lstr, ' \?\zs *\V' . l:aChar)
      let l:leadingStr = strpart(l:lstr, 0, l:matchIdx)
      let l:preDisplayWidth = strdisplaywidth(l:leadingStr)
      if l:preDisplayWidth < l:aliIdx
        call setline(l:lnum, substitute(
          \ l:lstr, 
          \ ' \?\zs *\ze\V' . l:aChar,
          \ repeat(' ', l:aliIdx - l:preDisplayWidth),
          \ ''
        \))
      endif
    endif
    let l:lnum += 1
  endwhile

  redraw
  echom "Aligned '" . l:aChar . "'s."

endfunction " }}}

" }}}

" Unaligning, or compressing {{{

" Reversing aligning operation, removing extra spaces
nmap <leader>unali <Plug>AligncharacterUndo
xmap <leader>unali <Plug>AligncharacterUndo
nnoremap <script> <Plug>AligncharacterUndo <SID>Undo
xnoremap <script> <Plug>AligncharacterUndo <SID>Undo
nnoremap <SID>Undo :call <SID>Undo(mode())<CR>
xnoremap <SID>Undo :<C-U>call <SID>Undo(visualmode())<CR>

function! s:Undo(mode, ...)

  let [l:startLN, l:endLN] = a:mode ==? visualmode()
    \ ? [line("'<"), line("'>")]
    \ : [line("."), line("$")]

  if exists('a:1')
    let l:aChar = a:1
  else
    echo 'Remove extra spaces preceding which character? '
    let l:aChar = nr2char(getchar())
  endif
  let l:aChar = escape(l:aChar, '\/')
  redraw
  execute l:startLN . ',' . l:endLN . 's/ \+\ze \V' . l:aChar . '//e'
  nohlsearch

endfunction

" }}}

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
