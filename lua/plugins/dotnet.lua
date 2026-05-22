return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
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
