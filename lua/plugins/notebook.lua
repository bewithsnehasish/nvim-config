return {
  {
    "ajbucci/ipynb.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
      "folke/snacks.nvim",
    },
    ft = { "ipynb" },
    config = function()
      require("ipynb").setup {
        kernel = {
          python_path = nil, -- nil = auto-detect .venv
          show_status = true,
        },
        shadow = {
          location = "workspace", -- recommended for pyright diagnostics
        },
        cell = {
          border = "rounded",
          show_fold_column = true,
        },
        format = {
          enabled = true,
        },
        output = {
          max_lines = 30,
        },
      }
    end,
  },
}
