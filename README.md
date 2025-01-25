Add and extend [Obsidian-like pasting](https://help.obsidian.md/User+interface/Drag+and+drop) to Vim/Neovim. The plugin allows you to paste rich text (e.g., HTML or text from office software) from the clipboard as [Markdown](https://en.wikipedia.org/wiki/Markdown), [Org Syntax](https://orgmode.org/worg/org-syntax.html), or [LaTeX](https://en.wikipedia.org/wiki/LaTeX) using [Pandoc](https://pandoc.org).

# Requirements

- [Pandoc](https://pandoc.org) (in your `$PATH`)
- A system clipboard tool that can output HTML (e.g., `xclip` or `pbpaste`)

# Installation

It’s quite simple using your favorite plugin manager. Below are a couple of examples.

## Using vim-plug

```vim
" In your .vimrc or init.vim:
call plug#begin('~/.vim/plugged')
  Plug 'petRUShka/pandoc_paste.vim'
call plug#end()
```

Then run `:PlugInstall` to install the plugin.

## Using lazy.nvim

```lua
{
  "petRUShka/pandoc_paste.vim",
  config = function()
    -- Example: disable default mapping
    -- vim.g.pandoc_paste_no_mapping = 1
  end
}
```

Then run `:Lazy sync`.

# Usage

- **Command:** `:PandocPaste`  
  Converts clipboard HTML to a format based on the current `filetype`:
  - `markdown`, `pandoc` → HTML → Markdown
  - `org` → HTML → Org
  - `latex` → HTML → LaTeX
  - otherwise → raw paste

- **Default Key:** `<leader>p`  
  Puts converted (or raw) text after the current line.

# Configuration

By default, `<leader>p` calls `:PandocPaste`. Disable or change this if you like:

```vim
" Disable the default mapping before plugin load:
let g:pandoc_paste_no_mapping = 1

" Then define your own mapping:
nnoremap <silent> <leader>h :PandocPaste<CR>
```

Use `g:pandoc_paste_command` to specify a custom command for retrieving HTML. For example:

```vim
" If you're on Wayland, you might use:
let g:pandoc_paste_command = 'wl-paste --type text/html'
```

# Author & License

Author: **petRUShka**  
License: **MIT**
