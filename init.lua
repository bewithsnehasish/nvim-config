-- Initialize lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.neovide_font = "Cascadia Code:h12"
vim.g.neovide_font_features = { "calt", "ss01" }

-- Require vim-options and lazy setup
require "vim-options"
require("lazy").setup "plugins"

--Load Keymaps plugins in the interface
require "keymaps"
