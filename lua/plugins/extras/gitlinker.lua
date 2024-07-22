return {
  "linrongbin16/gitlinker.nvim",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  event = "VeryLazy",
  keys = {
    { "<leader>gy", "<cmd>GitLink!<cr>", desc = "Git link" },
    { "<leader>gY", "<cmd>GitLink blam<cr>", desc = "Git link blame" },
  },
  config = function()
    require("gitlinker").setup {
      message = false,
      console_log = false,
    }
  end,
}
