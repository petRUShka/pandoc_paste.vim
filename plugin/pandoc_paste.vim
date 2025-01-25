" pandoc_paste.vim
" ---------------------------------------------------------------------
" Version: 1.0.0
" Author: petRUShka
" ---------------------------------------------------------------------

if exists('g:loaded_pandoc_paste')
  finish
endif
let g:loaded_pandoc_paste = 1

function! pandoc_paste#IsPipelineRunnable(command) abort
  " Split on the pipe symbol
  let l:piped_cmds = split(a:command, '|')
  for l:cmd in l:piped_cmds
    " Trim whitespace
    let l:cmd = trim(l:cmd)
    " Get first token (the executable name)
    let l:first_token = matchstr(l:cmd, '^\S\+')
    " If it’s empty or not executable, we fail
    if empty(l:first_token) || executable(l:first_token) == 0
      return 0
    endif
  endfor
  return 1
endfunction

function! pandoc_paste#GetClipboardCommand(for_html) abort
  if exists('g:pandoc_paste_command') && g:pandoc_paste_command !=# ''
    return g:pandoc_paste_command
  endif

  if has('macunix')
    return 'pbpaste'
  elseif has('unix')
    if a:for_html
      return 'xclip -selection clipboard -o -t text/html'
    else
      return 'xclip -selection clipboard -o'
    endif
  elseif has('win32') || has('win64')
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
    let l:cmd = pandoc_paste#GetClipboardCommand(0)
    if empty(l:cmd)
      echoerr '[pandoc_paste] Error: No valid clipboard command found.'
      return
    endif
  endif

  " Check entire pipeline before execution
  if !pandoc_paste#IsPipelineRunnable(l:cmd)
    echoerr '[pandoc_paste] Error: Command not found in pipeline: ' . l:cmd
    return
  endif

  " Execute command, split by newlines, insert after current line
  let l:lines = split(system(l:cmd), "\n")
  call append(line('.'), l:lines)
endfunction

command! PandocPaste call pandoc_paste#Paste()

if !exists('g:pandoc_paste_no_mapping')
  nnoremap <silent> <leader>p :PandocPaste<CR>
endif
