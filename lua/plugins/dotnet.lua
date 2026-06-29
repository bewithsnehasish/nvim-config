return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "vb" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("lang.dotnet").setup()
    end,
    keys = {
      { "<leader>pt", "<cmd>Roslyn target<cr>", desc = "Roslyn target" },
      { "<leader>pr", "<cmd>Roslyn restart<cr>", desc = "Roslyn restart" },
    },
  },
}
