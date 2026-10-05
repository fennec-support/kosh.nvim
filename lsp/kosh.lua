-- Koshka's language server for Neovim 0.11+. Neovim loads this file from
-- 'runtimepath' when the "kosh" configuration is enabled.

-- Koshka finds embedded shell in a justfile by its file name. A buffer named
-- foo.just is a justfile to Neovim and an ordinary shell script to the server.
-- The server is kept away from it.
local function is_analyzable_buffer(bufnr)
  if vim.bo[bufnr].filetype ~= "just" then
    return true
  end

  local name = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)):lower()
  return name == "justfile" or name == ".justfile"
end

return {
  cmd = { "kosh", "--as-language-server" },
  get_language_id = function(_, filetype)
    if filetype == "yaml.ansible" then
      return "yaml"
    end
    if filetype == "make" then
      return "makefile"
    end
    return filetype
  end,
  filetypes = {
    "sh",
    "bash",
    "kosh",
    "shit",
    "yaml",
    "yaml.ansible",
    "markdown",
    "dockerfile",
    "make",
    "json",
    "jsonc",
    "just",
    "spec",
  },
  root_dir = function(bufnr, on_dir)
    if not is_analyzable_buffer(bufnr) then
      return
    end

    on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.root(bufnr, { "Makefile" }) or vim.fn.getcwd())
  end,
}
