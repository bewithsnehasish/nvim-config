return {
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Spectre",
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").open()
        end,
        desc = "Search & replace (project)",
      },
      {
        "<leader>sw",
        function()
          require("spectre").open_visual { select_word = true }
        end,
        desc = "Search word under cursor (project)",
      },
      {
        "<leader>sw",
        function()
          require("spectre").open_visual()
        end,
        mode = "v",
        desc = "Search selection (project)",
      },
      {
        "<leader>sf",
        function()
          require("spectre").open_file_search { select_word = true }
        end,
        desc = "Search & replace in current file",
      },
    },
    opts = {
      open_cmd = "noswapfile vnew",
      -- Use ripgrep (already installed) for fast searching
      find_engine = {
        ["rg"] = {
          cmd = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--pcre2", -- enables lookaheads / lookbehinds for complex patterns
          },
          options = {
            ["ignore-case"] = { value = "--ignore-case", icon = "[I]", desc = "ignore case" },
            ["hidden"] = { value = "--hidden", icon = "[H]", desc = "hidden file" },
          },
        },
      },
    },
  },
}
