" Aligning  {{{
" Ask user for a character and align the 1st of that character in every line
" from current line to the end by inserting spaces. In visual mode, do the
" same thing only for the selected lines.
nnoremap <leader>ali :call Align(mode())<CR>
vnoremap <leader>ali :<C-u>call Align(visualmode())<CR>

function! Align(mode, ...) " {{{

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
    " is not usually equal to its displaying width, namely 2. Thus the
    " aligning operation will insert a wrong number of, in fact less, spaces
    " if some Chinese characters precede the aligned character.
    " To insure the function match count such a character also as 2 indices
    " (byte offset), one can set 'encoding' to cp936 or gbk before opening
    " the file and performing alignment.
    " Reference: http://littlewhite.us/archives/387

    let l:matchIdx = match(getline(l:lnum), ' \?\zs *\V' . l:aChar)
    if l:aliIdx < l:matchIdx
      let l:aliIdx = l:matchIdx
    endif
    let l:lnum += 1
  endwhile

  let l:lnum = l:startLN
  while l:lnum <= l:endLN
    let l:lstr = getline(l:lnum)
    " l:aCharIdx is where the aligned character exactly is.
    let l:aCharIdx = match(l:lstr, '\V' . l:aChar)
    if l:aCharIdx >= 0 && l:aCharIdx != l:aliIdx
      let l:matchIdx = match(l:lstr, ' \?\zs *\V' . l:aChar)
      call setline(l:lnum, substitute(
        \ l:lstr, 
        \ ' \?\zs *\ze\V' . l:aChar,
        \ repeat(' ', l:aliIdx - l:matchIdx),
        \ ''
      \))
    endif
    let l:lnum += 1
  endwhile

  redraw
  echom "Aligned '" . l:aChar . "'s."

endfunction " }}}

function! Align_(mode, ...) " {{{

  " This is an alternative version of function Align, which does the same
  " thing but in a different way. It doesn't remove extra spaces at the same
  " time it aligns a character. Instead, it removes extra spaces first, by
  " calling function Compress, then aligns the characters.

  let [l:startLN, l:endLN] = visualmode()
    \ ? [line("'<"), line("'>")]
    \ : [line("."), line("$")]

  if exists('a:1')
    let l:aChar = a:1
  else
    echo 'Align which character? '
    let l:aChar = nr2char(getchar())
  endif

  " Remove extra spaces first. If you don't want do this, simply comment out
  " this function call.
  " This call has a side effect that it changes every line even if that line
  " would revert to its exact original state after inserting spaced back. This
  " makes comparing l:matchIdx and l:matchIdx in the if-statement below which
  " wraps the setline function call mostly unnecessary for avoiding
  " unnecessary replace operation.
  call Compress(a:mode, l:aChar)

  " Find the align position which is the greatest one of the to-be-aligned
  " character's column indices.
  let l:lnum = l:startLN
  let l:aliIdx = 0
  while l:lnum <= l:endLN

    " A multibyte character such as a Chinese character needs 2 to 4 bytes to
    " store in memory, when the option 'encoding' is set to utf-8, which is
    " not usually equal to its displaying width, namely 2. Thus the aligning
    " operation will insert a wrong number of, in fact less, spaces if some
    " Chinese characters precede the aligned character.
    " To insure the function match count such a character also as 2 indices
    " (byte offset), one can set 'encoding' to cp936 or gbk before opening
    " the file and performing alignment.
    " Reference: http://littlewhite.us/archives/387
    
    let l:matchIdx = match(getline(l:lnum), '\V' . l:aChar)
    if l:aliIdx < l:matchIdx
      let l:aliIdx = l:matchIdx
    endif
    let l:lnum += 1
  endwhile

  let l:lnum = l:startLN
  while l:lnum <= l:endLN
    let l:matchIdx = match(getline(l:lnum), '\V' . l:aChar)
    if l:matchIdx >= 0 && l:matchIdx < l:aliIdx
      call setline(l:lnum, substitute(
        \ getline(l:lnum), 
        \ '\ze\V' . l:aChar,
        \ repeat(' ', l:aliIdx - l:matchIdx),
        \ ''
      \))
    endif
    let l:lnum += 1
  endwhile

  redraw
  echom "Aligned '" . l:aChar . "'s."

endfunction " }}}

" }}}

" De-aligning, or compressing {{{

" Reversing aligning operation, removing extra spaces
nnoremap <leader>comp :call Compress(mode())<CR>
vnoremap <leader>comp :<C-u>call Compress(visualmode())<CR>

function! Compress(mode, ...)

  let [l:startLN, l:endLN] = a:mode ==? visualmode()
    \ ? [line("'<"), line("'>")]
    \ : [line("."), line("$")]

  if exists('a:1')
    let l:aChar = a:1
  else
    echo 'Remove extra spaces preceding which character? '
    let l:aChar = nr2char(getchar())
  endif
  let l:aChar = escape(l:aChar, '\')
  redraw
  execute l:startLN . ',' . l:endLN . 's/ \+\ze \V' . l:aChar . '//e'
  nohlsearch

endfunction

" }}}
