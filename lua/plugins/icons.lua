return {
  {
    "nvim-tree/nvim-web-devicons",
    tag = "nerd-v2-compat",
    config = function()
      require("nvim-web-devicons").setup {
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh",
          },
        },
        color_icons = true,
        default = true,
        strict = true,
        override_by_filename = {
          [".gitignore"] = {
            icon = "",
            color = "#f1502f",
            name = "Gitignore",
          },
        },
        override_by_extension = {
          ["log"] = {
            icon = "",
            color = "#81e043",
            name = "Log",
          },
        },
        override_by_operating_system = {
          ["apple"] = {
            icon = "",
            color = "#A2AAAD",
            cterm_color = "248",
            name = "Apple",
          },
        },
      }
    end,
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Configure modules of mini.nvim
      require("mini.surround").setup {}
      require("mini.comment").setup {}
      require("mini.pairs").setup {}
      require("mini.statusline").setup {}
      require("mini.tabline").setup {}
      -- Add more mini.nvim modules as needed
    end,
  },
}
