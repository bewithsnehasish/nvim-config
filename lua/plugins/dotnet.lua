return {
  {
    "seblyng/roslyn.nvim",
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("lang.dotnet").setup()
    end,
    keys = {
      { "<leader>ct", "<cmd>Roslyn target<cr>", desc = "Roslyn target" },
      { "<leader>cR", "<cmd>Roslyn restart<cr>", desc = "Roslyn restart" },
    },
  },
}
