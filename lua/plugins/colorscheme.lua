-- Three colorschemes, switchable any time with `<leader>fc`
-- (snacks picker shows all with live preview).
--
-- To change the boot default: edit the `vim.cmd.colorscheme(...)` line in the
-- cyberdream block below, OR set vim.g.default_colorscheme before lazy loads.

return {
  -- ── 1. Cyberdream (default) ─────────────────────────────────────────────────
  -- :colorscheme cyberdream
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup {
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_telescope = true,
        terminal_colors = true,
      }
      vim.cmd.colorscheme(vim.g.default_colorscheme or "cyberdream")
    end,
  },

  -- ── 2. Tokyo Night ──────────────────────────────────────────────────────────
  -- Four styles: night, storm, moon, day (light).
  -- :colorscheme tokyonight-storm | tokyonight-night | tokyonight-moon | tokyonight-day
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
        keywords = { italic = false },
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.FloatBorder = { fg = c.blue1, bg = "NONE" }
      end,
    },
  },

  -- ── 3. Kanagawa ─────────────────────────────────────────────────────────────
  -- Inspired by The Great Wave. Three variants: wave (default), dragon (darker), lotus (light).
  -- :colorscheme kanagawa-wave | kanagawa-dragon | kanagawa-lotus
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      compile = false,
      undercurl = true,
      transparent = true,
      theme = "wave",
      background = { dark = "wave", light = "lotus" },
    },
  },
}
