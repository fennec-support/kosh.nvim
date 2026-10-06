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

-- Reports the Neovim version, the kosh executable, and the LSP configuration
-- for :checkhealth kosh.

local M = {}

local VERSION_TIMEOUT_MS = 2000

local function check_neovim()
  local version = vim.version()
  local version_text = string.format("%d.%d.%d", version.major, version.minor, version.patch)
  if vim.fn.has("nvim-0.11") == 1 then
    vim.health.ok("Neovim " .. version_text)
  else
    vim.health.error("Neovim " .. version_text .. " is too old", { "kosh.nvim requires Neovim 0.11 or newer" })
  end
end

local function check_executable()
  if vim.fn.executable("kosh") ~= 1 then
    vim.health.error("`kosh` is not executable or not on $PATH", {
      "kosh.nvim does not download kosh",
      "Install it from https://github.com/fennec-support/kosh",
    })
    return false
  end

  vim.health.ok("`kosh` found at " .. vim.fn.exepath("kosh"))
  return true
end

local function check_version()
  local was_started, process = pcall(vim.system, { "kosh", "--version" }, { text = true })
  if not was_started then
    vim.health.error("`kosh --version` failed to start: " .. tostring(process))
    return
  end

  local result = process:wait(VERSION_TIMEOUT_MS)
  if result.signal ~= 0 or result.code == 124 then
    vim.health.warn(string.format("`kosh --version` did not finish within %d ms", VERSION_TIMEOUT_MS))
    return
  end

  if result.code ~= 0 then
    vim.health.error(string.format("`kosh --version` exited with status %d", result.code))
    return
  end

  local version_line = vim.split(result.stdout or "", "\n", { plain = true })[1]
  if version_line == nil or version_line == "" then
    vim.health.warn("`kosh --version` printed no version")
    return
  end

  vim.health.ok(version_line)
end

local function check_lsp_config()
  local was_resolved, config = pcall(function()
    return vim.lsp.config.kosh
  end)
  if not was_resolved or config == nil then
    vim.health.error("The `kosh` LSP configuration is not registered", {
      "Make sure kosh.nvim is on 'runtimepath' so that lsp/kosh.lua is found",
    })
    return
  end

  vim.health.ok("The `kosh` LSP configuration is registered")

  if vim.lsp.is_enabled == nil then
    vim.health.info("This Neovim cannot report whether the `kosh` LSP configuration is enabled")
    return
  end

  if vim.lsp.is_enabled("kosh") then
    vim.health.ok("The `kosh` LSP configuration is enabled")
  else
    vim.health.warn("The `kosh` LSP configuration is not enabled", {
      'Call require("kosh").setup()',
    })
  end
end

function M.check()
  vim.health.start("kosh.nvim")

  check_neovim()
  if vim.fn.has("nvim-0.11") ~= 1 then
    return
  end

  if check_executable() then
    check_version()
  end

  check_lsp_config()
end

return M
