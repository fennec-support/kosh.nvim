# kosh.nvim

This plugin runs the [Koshka](https://github.com/fennec-support/kosh) language
server in Neovim 0.11 and newer. The server provides shell diagnostics,
completion, hover, rename, and formatting.

## Requirements

- Neovim 0.11 or newer.
- `kosh` on `PATH`. See the
  [Koshka install instructions](https://github.com/fennec-support/kosh).
- Optional: the `bash` tree-sitter parser for highlighting. The plugin reuses
  it for `sh`, `bash`, `kosh`, and `shit` buffers.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "fennec-support/kosh.nvim", lazy = false, opts = {} }
```

Keep `lazy = false`. With `ft` loading, a `.kosh` buffer opened first never gets
the `kosh` filetype, because the plugin that registers it has not loaded yet,
and the server never starts.

Without a plugin manager, add the repository to `runtimepath` and call:

```lua
require("kosh").setup({})
```

## Options

| Option | Default | Meaning |
|---|---|---|
| `format_on_save` | `true` | Format with the server before each write. |
| `filetypes` | `nil` | Replace the list of filetypes the server attaches to. |

The server attaches to `sh`, `bash`, `kosh`, and `shit` buffers. It also
attaches to `yaml`, `yaml.ansible`, `markdown`, `json`, `jsonc`, `dockerfile`,
`make`, `just`, and `spec` buffers, where it checks embedded shell. To narrow
the list:

```lua
opts = { filetypes = { "sh", "bash", "kosh" } }
```

A file named `foo.just` is a justfile to Neovim but a plain shell script to the
server, so the server only attaches to `justfile` and `.justfile` buffers.

## bashls

If bashls also runs on the same buffers, you see every problem twice. Disable
one of the two servers for shell filetypes.

## Without the language server

`kosh --format` formats standard input. See `:help kosh-format` for a
conform.nvim recipe.

## License

BSD 3-Clause. See [LICENSE](LICENSE).
