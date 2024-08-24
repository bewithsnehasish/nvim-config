return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#7b8496",
        cterm = 244,
      },
      log_level = "info", -- Set to "off" to disable logging
      disable_inline_completion = false, -- Disable inline completion if using with cmp
      disable_keymaps = false, -- Disable built-in keymaps for manual control
    }
  end,
}
