[Obsidian-like pasting](https://help.obsidian.md/User+interface/Drag+and+drop) for Vim/Neovim. The plugin allows you to paste rich text (e.g., HTML or text from office software) from the clipboard as [Markdown](https://en.wikipedia.org/wiki/Markdown), [Org Syntax](https://orgmode.org/worg/org-syntax.html), or [LaTeX](https://en.wikipedia.org/wiki/LaTeX) using [Pandoc](https://pandoc.org). It strips many unnecessary HTML tags by default by going through [Org](https://orgmode.org/).

# Requirements

- [Pandoc](https://pandoc.org) (must be in your `$PATH`)
- A system clipboard tool that can output HTML (e.g., `xclip`, `wl-paste`, `pbpaste`, or `powershell.exe -command Get-Clipboard`)

# Installation

Use your preferred plugin manager. Examples:

## Using vim-plug

```vim
" In your .vimrc or init.vim:
call plug#begin('~/.vim/plugged')
  Plug 'petRUShka/pandoc_paste.vim'
call plug#end()
```

Then run `:PlugInstall`.

## Using lazy.nvim

``` lua
{
  "petRUShka/pandoc_paste.vim",
  config = function()
    -- Example: disable default mapping
    -- vim.g.pandoc_paste_no_mapping = 1
  end
}
```

Then perform the appropriate install/update step (e.g., `:Lazy sync`).

# Usage

- **Command**: `:PandocPaste`  
  Pulls from the system clipboard (HTML if available) and converts it depending on the current `filetype`:
  
  - `markdown`, `pandoc`: HTML → Org → CommonMark (by default)  
  - `org`: HTML → Org  
  - `latex`: HTML → Org → LaTeX  
  - anything else: raw paste

- **Default Key**: `<leader>p`  
  Inserts converted (or raw) text after the current line.

# Intermediate Org Conversion

By default, the plugin uses the trick to avoid preserving unnecessary attributes. It does HTML → Org → final for recognized filetypes.  
- Converting to Markdown uses `commonmark` to yield cleaner output.  
- If you prefer **direct** HTML → `markdown_strict` (or LaTeX, etc.), disable the Org step:

```vim
let g:pandoc_paste_use_org_intermediate = 0
```

# Configuration

Disable the default mapping before the plugin loads, or override it:

```vim
let g:pandoc_paste_no_mapping = 1

nnoremap <silent> <leader>h :PandocPaste<CR>
```

Specify a custom command for retrieving HTML:
    
```vim
let g:pandoc_paste_command = 'wl-paste --type text/html'
```

# Author & License

- Author: **petRUShka**  
- License: **MIT**
