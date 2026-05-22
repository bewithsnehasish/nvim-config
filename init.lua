-- Byte-compile + cache all Lua modules on first load. ~30ms off cold start,
-- bigger win on hot reloads. Must run BEFORE any require() call.
vim.loader.enable()

-- Disable vendored default plugins we don't use — saves rtp scan + sourcing time.
local disabled_builtins = {
  "netrwPlugin", "netrwSettings", "netrwFileHandlers", -- using neo-tree
  "gzip", "tarPlugin", "tar", "zipPlugin", "zip", -- using snacks for archives
  "matchparen", -- treesitter handles bracket matching
  "tutor", "rplugin", -- unused
  "tohtml",
  "2html_plugin",
  "logiPat",
  "rrhelper",
  "spellfile_plugin",
}
for _, name in ipairs(disabled_builtins) do
  vim.g["loaded_" .. name] = 1
end

-- Initialize lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require "core.options"
require("lazy").setup "plugins"
require "core.keymaps"
