-- Opens a shell script and fails unless a client named "kosh" attaches.
-- Run from the repository root:
--   nvim --headless --clean -c "luafile tests/attach.lua"

vim.opt.runtimepath:prepend(vim.fn.getcwd())
require("kosh").setup({})

vim.cmd.edit("tests/fixture.sh")

local has_attached = vim.wait(15000, function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "kosh" }) > 0
end, 100)

if not has_attached then
  io.stderr:write("kosh did not attach to tests/fixture.sh\n")
  vim.cmd("cquit 1")
end

io.stdout:write("kosh attached to tests/fixture.sh\n")
vim.cmd("qall!")
