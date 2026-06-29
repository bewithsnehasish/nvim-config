return {
  {
    "ckob/lazydotnet.nvim",
    cmd = "LazyDotnet",
    keys = {
      { "<leader>pd", "<cmd>LazyDotnet<cr>", desc = "Toggle LazyDotnet" },
      { "<M-d>", "<cmd>LazyDotnet<cr>", mode = { "n", "t" }, desc = "Toggle LazyDotnet" },
    },
    opts = {
      cmd = { "lazydotnet" },
      window = {
        width_ratio = 0.85,
        height_ratio = 0.85,
        border = "rounded",
      },
    },
  },
}
