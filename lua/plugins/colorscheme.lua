return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Automatically override terminal colors to ensure high contrast for TUI tools 
      -- (like lazygit and lazydotnet) on transparent/black backgrounds.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TerminalColorsOverride", { clear = true }),
        callback = function()
          vim.g.terminal_color_8 = "#7b8496" -- High-contrast grey for inactive tabs/items
          vim.g.terminal_color_0 = "#16181a" -- Dark grey/black
        end,
      })

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
            SnacksPickerGitStatusUntracked = { fg = colors.cyan },
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
