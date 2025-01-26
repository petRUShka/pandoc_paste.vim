" pandoc_paste.vim
" Version: 1.2.x
" Author: petRUShka

if exists('g:loaded_pandoc_paste')
  finish
endif
let g:loaded_pandoc_paste = 1

function! pandoc_paste#NeedsPandoc(target_fmt, use_org_intermediate) abort
  if empty(a:target_fmt)
    return 0
  endif
  if a:target_fmt ==# 'org' && a:use_org_intermediate
    return 1
  endif
  return 1
endfunction

function! pandoc_paste#BuildPipeline(target_fmt, use_org_intermediate) abort
  if empty(a:target_fmt)
    return pandoc_paste#GetClipboardCommand(0)
  endif

  let l:cmd = pandoc_paste#GetClipboardCommand(1)
  if empty(l:cmd)
    return ''
  endif

  if a:use_org_intermediate && a:target_fmt !=# 'org'
    " 'markdown_strict' is better in raw HTML -> Markdown conversion
    " 'commonmark' is better in case of HTLM -> Org -> Markdown conversion
    let l:final_fmt = a:target_fmt
    if l:final_fmt ==# 'markdown_strict'
      let l:final_fmt = 'commonmark'
    endif

    return l:cmd . ' | pandoc -f html -t org | pandoc -f org -t ' . l:final_fmt
  elseif
    return l:cmd . ' | pandoc -f html -t ' . a:target_fmt
  endif
endfunction

function! pandoc_paste#Paste() abort
  let l:use_org_intermediate = get(g:, 'pandoc_paste_use_org_intermediate', 1)
  let l:target_fmt = pandoc_paste#GetPandocOutputFormat(&filetype)

  if pandoc_paste#NeedsPandoc(l:target_fmt, l:use_org_intermediate)
    if executable('pandoc') == 0
      echoerr '[pandoc_paste] Error: pandoc is missing or not in $PATH.'
      return
    endif
  endif

  let l:cmd = pandoc_paste#BuildPipeline(l:target_fmt, l:use_org_intermediate)
  if empty(l:cmd)
    echoerr '[pandoc_paste] Error: No valid clipboard command found.'
    return
  endif

  if !pandoc_paste#IsPipelineRunnable(l:cmd)
    echoerr '[pandoc_paste] Error: Command not found in pipeline: ' . l:cmd
    return
  endif

  let l:lines = split(system(l:cmd), "\n")
  call append(line('.'), l:lines)
endfunction

function! pandoc_paste#IsPipelineRunnable(command) abort
  let l:piped_cmds = split(a:command, '|')
  for l:cmd in l:piped_cmds
    let l:cmd = trim(l:cmd)
    let l:first_token = matchstr(l:cmd, '^\S\+')
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
        \ 'pandoc': 'markdown_strict',
        \ 'org': 'org',
        \ 'tex': 'latex'
        \ }
  return get(l:formats, a:ft, '')
endfunction

command! PandocPaste call pandoc_paste#Paste()

if !exists('g:pandoc_paste_no_mapping')
  nnoremap <silent> <leader>p :PandocPaste<CR>
endif
