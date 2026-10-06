-- Copyright 2026 toiletbril
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its
-- contributors may be used to endorse or promote products derived from this
-- software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

local M = {}

local defaults = {
  format_on_save = false,
  additional_filetypes = {},
}

local function append_filetypes(additional_filetypes)
  local filetypes = vim.deepcopy(vim.lsp.config.kosh.filetypes)
  local seen = {}
  for _, filetype in ipairs(filetypes) do
    seen[filetype] = true
  end

  for _, filetype in ipairs(additional_filetypes) do
    if not seen[filetype] then
      seen[filetype] = true
      table.insert(filetypes, filetype)
    end
  end

  vim.lsp.config("kosh", { filetypes = filetypes })
end

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

  if #opts.additional_filetypes > 0 then
    append_filetypes(opts.additional_filetypes)
  end

  vim.lsp.enable("kosh")

  if opts.format_on_save then
    enable_format_on_save()
  end
end

return M
