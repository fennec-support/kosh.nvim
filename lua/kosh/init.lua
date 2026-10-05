-- Sets up Koshka's language server and format-on-save in Neovim 0.11+. The
-- server configuration itself lives in lsp/kosh.lua.

local M = {}

local defaults = {
  format_on_save = true,
  filetypes = nil,
}

local function register_filetypes()
  vim.filetype.add({
    extension = {
      sh = "sh",
      bash = "bash",
      kosh = "kosh",
      shit = "shit",
    },
  })
  vim.treesitter.language.register("bash", {
    "sh",
    "bash",
    "kosh",
    "shit",
  })
end

local function enable_format_on_save()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kosh.format", { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client == nil or client.name ~= "kosh" then
        return
      end

      if not client:supports_method("textDocument/formatting") then
        return
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("kosh.format." .. event.buf, { clear = true }),
        buffer = event.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = event.buf, id = client.id, timeout_ms = 2000 })
        end,
      })
    end,
  })
end

function M.setup(opts)
  if vim.fn.has("nvim-0.11") ~= 1 then
    vim.notify("kosh.nvim requires Neovim 0.11 or newer", vim.log.levels.ERROR)
    return
  end

  opts = vim.tbl_extend("force", defaults, opts or {})

  register_filetypes()

  if opts.filetypes ~= nil then
    vim.lsp.config("kosh", { filetypes = opts.filetypes })
  end

  vim.lsp.enable("kosh")

  if opts.format_on_save then
    enable_format_on_save()
  end
end

return M
