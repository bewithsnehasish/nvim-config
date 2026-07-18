return {
  "alexghergh/nvim-tmux-navigation",
  keys = {
    { "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", desc = "Tmux left" },
    { "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", desc = "Tmux down" },
    { "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", desc = "Tmux up" },
    { "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", desc = "Tmux right" },
  },
  opts = {
    disable_when_zoomed = true, -- Prevents accidental navigation out of zoomed panes
  },
  config = function(_, opts)
    require("nvim-tmux-navigation").setup(opts)
  end,
}
