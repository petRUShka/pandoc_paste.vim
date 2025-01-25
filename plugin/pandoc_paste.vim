" pandoc_paste.vim
" ---------------------------------------------------------------------
" Version: 1.0.0
" Author: petRUShka
" ---------------------------------------------------------------------

if exists('g:loaded_pandoc_paste')
  finish
endif
let g:loaded_pandoc_paste = 1

" If you want to override default commands, define g:pandoc_paste_command
" in your vimrc before loading this plugin. Otherwise, the function below
" picks a platform-specific default.

function! pandoc_paste#GetClipboardCommand(for_html) abort
  if exists('g:pandoc_paste_command') && g:pandoc_paste_command !=# ''
    return g:pandoc_paste_command
  endif

  if has('macunix')
    " macOS: pbpaste only returns plain text by default or don't work at all 
    " (wasn't tested)
    " More advanced retrieval of text/html might need AppleScript approach
    return 'pbpaste'
  elseif has('unix')
    if a:for_html
      return 'xclip -selection clipboard -o -t text/html'
    else
      return 'xclip -selection clipboard -o'
    endif
  elseif has('win32') || has('win64')
    " Windows: powershell
    " Note: might not retrieve HTML in all cases or don't work at all (wasn't
    " tested)
    return 'powershell.exe -noprofile -command Get-Clipboard'
  endif

  return ''
endfunction

function! pandoc_paste#GetPandocOutputFormat(ft) abort
  let l:formats = {
        \ 'markdown': 'markdown_strict',
        \ 'org': 'org',
        \ 'pandoc': 'markdown_strict',
        \ 'latex': 'latex'
        \ }

  " Return empty for unknown => triggers raw text
  return get(l:formats, a:ft, '')
endfunction

function! pandoc_paste#Paste() abort
  let l:target_fmt = pandoc_paste#GetPandocOutputFormat(&filetype)

  if !empty(l:target_fmt)
    let l:cmd = pandoc_paste#GetClipboardCommand(1)
    if empty(l:cmd)
      echoerr '[pandoc_paste] Error: No valid clipboard command found.'
      return
    endif
    let l:cmd .= ' | pandoc -f html -t ' . l:target_fmt

  else
    " Unknown filetype => paste raw text
    let l:cmd = pandoc_paste#GetClipboardCommand(0)
    if empty(l:cmd)
      echoerr '[pandoc_paste] Error: No valid clipboard command found.'
      return
    endif
  endif

  " Execute command, split by newlines, insert after current line
  let l:lines = split(system(l:cmd), "\n")
  call append(line('.'), l:lines)
endfunction

command! PandocPaste call pandoc_paste#Paste()

if !exists('g:pandoc_paste_no_mapping')
  nnoremap <silent> <leader>p :PandocPaste<CR>
endif
