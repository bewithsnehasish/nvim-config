return {
  "neogitorg/neogit",
  event = "VeryLazy",
  keys = {
    { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit" },
  },
  config = function()
    local icons = require "plugins.user.icons"
    require("neogit").setup {
      auto_refresh = true,
      disable_builtin_notifications = false,
      use_magit_keybindings = false,
      kind = "tab",
      commit_popup = {
        kind = "split",
      },
      popup = {
        kind = "split",
      },
      signs = {
        section = { icons.ui.ChevronRight, icons.ui.ChevronShortDown },
        item = { icons.ui.ChevronRight, icons.ui.ChevronShortDown },
        hunk = { "", "" },
      },
    }
  end,
}
