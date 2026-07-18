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

require("lazy").setup {
  spec = {
    { import = "plugins" },
    { import = "plugins.extras" },
  },
  ui = {
    border = "rounded",
    backdrop = 80,
    icons = {
      cmd = " ",
      config = "",
      event = " ",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = " ",
      task = "✔ ",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
        "rplugin",
        "spellfile_plugin",
        "2html_plugin",
        "logiPat",
        "rrhelper",
      },
    },
  },
}

require "core.keymaps"
