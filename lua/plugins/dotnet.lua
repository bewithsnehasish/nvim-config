return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("lang.dotnet").setup()
    end,
    keys = {
      { "<leader>pt", "<cmd>Roslyn target<cr>", desc = "Roslyn target" },
      { "<leader>pr", "<cmd>lsp restart roslyn<cr>", desc = "Roslyn restart" },
    },
  },
}
