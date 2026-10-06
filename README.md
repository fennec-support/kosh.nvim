# kosh.nvim

This repository hosts [Koshka Shell](https://github.com/fennec-support/kosh)
tooling for Neovim 0.11+.

Currently that includes:
- Linter
- LSP/Symbols
- Formatter

## Installation

Make sure you have:
- `kosh` on `PATH`. See the
  [Koshka install instructions](https://github.com/fennec-support/kosh).
- Optionally, tree-sitter parsers for shell highlighting.

With [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{ "fennec-support/kosh.nvim", lazy = false, opts = {} }
```

## Options

The defaults:
```lua
require("kosh").setup({
  -- Format the buffer with the server before each write.
  format_on_save = false,
  -- Filetypes appended to the built-in list: sh, bash, kosh, shit, yaml,
  -- yaml.ansible, markdown, dockerfile, make, json, jsonc, just, and spec.
  additional_filetypes = {},
})
```

## Documentation

[RTFM](doc/kosh.txt).

## bashls

Just disable it.
