return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup {
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_telescope = false,
        terminal_colors = true,
        overrides = function(colors)
          return {
            BufferLineFill = { bg = "NONE" },
            BufferLineBackground = { bg = "NONE" },
            BufferLineSeparator = { fg = colors.bg, bg = "NONE" },
            BufferLineSeparatorVisible = { fg = colors.bg, bg = "NONE" },
            BufferLineSeparatorSelected = { fg = colors.bg, bg = "NONE" },
          }
        end,
      }
      vim.cmd.colorscheme(vim.g.default_colorscheme or "cyberdream")
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      undercurl = true,
      transparent = true,
      theme = "wave",
      background = { dark = "wave", light = "lotus" },
    },
  },
}
