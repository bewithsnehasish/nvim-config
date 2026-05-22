-- Initialize lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require "core.options"
require("lazy").setup "plugins"
require "core.keymaps"
