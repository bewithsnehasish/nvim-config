return {
  "SmiteshP/nvim-navbuddy",
  dependencies = {
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>o", "<cmd>Navbuddy<cr>", desc = "Nav" },
    { "<m-s>", "<cmd>silent only | Navbuddy<cr>", desc = "Navbuddy (Full Screen)" },
    { "<m-o>", "<cmd>silent only | Navbuddy<cr>", desc = "Navbuddy (Full Screen)" },
  },
  config = function()
    local navbuddy = require "nvim-navbuddy"
    -- local actions = require("nvim-navbuddy.actions")
    navbuddy.setup {
      window = {
        border = "rounded",
      },
      icons = require("plugins.user.icons").kind,
      lsp = { auto_attach = true },
    }
  end,
}
