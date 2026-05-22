return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- ── Pill helpers ──────────────────────────────────────────────────────
      -- Round-end glyphs (Powerline range, present in any Nerd Font).
      -- Written as UTF-8 byte escapes because the literal chars get stripped
      -- by the editing pipeline.
      local LROUND = "\xee\x82\xb6" -- U+E0B6 round left edge
      local RROUND = "\xee\x82\xb4" -- U+E0B4 round right edge

      local function pill()
        return { left = LROUND, right = RROUND }
      end

      -- ── Make the bar background TRANSPARENT so gaps between pills are clear
      local function transparentize()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
      end
      transparentize()

      -- ── FIXED Catppuccin Mocha palette ────────────────────────────────────
      -- Hardcoded so the statusline pills look identical no matter which
      -- colorscheme is active (cyberdream / tokyonight / kanagawa / …).
      -- Source: https://github.com/catppuccin/palette (Mocha flavour).
      local p = {
        base = "#1e1e2e", -- pill text fg when sitting on a bright bg (mode pill)
        surface = "#313244", -- Surface0 — pill background for non-mode components
        fg = "#cdd6f4", -- Text — default pill foreground
        green = "#a6e3a1", -- mode NORMAL · diff added
        yellow = "#f9e2af", -- mode COMMAND · diff modified · warn
        red = "#f38ba8", -- mode REPLACE · diff removed · error
        blue = "#89b4fa", -- mode INSERT · filename
        mauve = "#cba6f7", -- mode VISUAL · branch · project · hint
        sky = "#89dceb", -- mode TERMINAL · info
        peach = "#fab387", -- wakatime · constants
        lavender = "#b4befe", -- accents
      }

      -- ── Mode-aware pill color ─────────────────────────────────────────────
      local function mode_pill_color()
        local m = vim.api.nvim_get_mode().mode
        local map = {
          n = p.green,
          i = p.blue,
          v = p.mauve,
          V = p.mauve,
          ["\22"] = p.mauve, -- C-V
          s = p.mauve,
          S = p.mauve,
          c = p.peach,
          R = p.red,
          r = p.red,
          t = p.sky,
        }
        return { bg = map[m] or map[m:sub(1, 1)] or p.green, fg = p.base, gui = "bold" }
      end

      -- ── Project root (folder name of cwd) ────────────────────────────────
      local function project_name()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end

      -- ── Wakatime today (reads vim-wakatime's cached today value) ─────────
      -- vim-wakatime writes to ~/.wakatime/today after each heartbeat. Falls
      -- back to nothing if the file doesn't exist (e.g. wakatime offline).
      local function wakatime_today()
        local f = io.open(vim.fn.expand "~/.wakatime/today", "r")
        if not f then
          return ""
        end
        local s = f:read "*a" or ""
        f:close()
        return (s:gsub("[\r\n]", ""))
      end

      -- ── Build the spec ────────────────────────────────────────────────────
      local function build_config()
        return {
          options = {
            icons_enabled = true,
            -- Theme that paints sections with the transparent statusline bg —
            -- so when a component DOESN'T override its color, it disappears
            -- into the gap rather than showing a colored block.
            theme = {
              normal = {
                a = { bg = "NONE", fg = p.fg },
                b = { bg = "NONE", fg = p.fg },
                c = { bg = "NONE", fg = p.fg },
                x = { bg = "NONE", fg = p.fg },
                y = { bg = "NONE", fg = p.fg },
                z = { bg = "NONE", fg = p.fg },
              },
              inactive = {
                a = { bg = "NONE", fg = p.fg },
                b = { bg = "NONE", fg = p.fg },
                c = { bg = "NONE", fg = p.fg },
                x = { bg = "NONE", fg = p.fg },
                y = { bg = "NONE", fg = p.fg },
                z = { bg = "NONE", fg = p.fg },
              },
            },
            -- Empty global separators — every component carries its OWN
            -- rounded separator via the `separator = pill()` field.
            component_separators = "",
            section_separators = "",
            disabled_filetypes = {
              statusline = { "alpha", "dashboard", "lazy", "mason", "neo-tree" },
            },
            globalstatus = true,
          },
          sections = {
            -- LEFT
            lualine_a = {
              {
                "mode",
                separator = pill(),
                padding = { left = 1, right = 1 },
                color = mode_pill_color,
              },
            },
            lualine_b = {
              {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                sections = { "error", "warn", "info", "hint" },
                symbols = { error = " ", warn = " ", info = " ", hint = " " },
                diagnostics_color = {
                  error = { fg = p.red, bg = p.surface },
                  warn = { fg = p.yellow, bg = p.surface },
                  info = { fg = p.sky, bg = p.surface },
                  hint = { fg = p.mauve, bg = p.surface },
                },
                colored = true,
                separator = pill(),
                color = { bg = p.surface, fg = p.fg },
                padding = { left = 1, right = 1 },
                cond = function()
                  return #vim.diagnostic.get(0) > 0
                end,
              },
              {
                wakatime_today,
                icon = "",
                separator = pill(),
                color = { bg = p.surface, fg = p.peach },
                padding = { left = 1, right = 1 },
                cond = function()
                  return wakatime_today() ~= ""
                end,
              },
            },
            lualine_c = {},

            -- RIGHT
            lualine_x = {
              {
                "branch",
                icon = "",
                separator = pill(),
                color = { bg = p.surface, fg = p.mauve },
                padding = { left = 1, right = 1 },
              },
              {
                "diff",
                symbols = { added = " ", modified = " ", removed = " " },
                diff_color = {
                  added = { fg = p.green, bg = p.surface },
                  modified = { fg = p.yellow, bg = p.surface },
                  removed = { fg = p.red, bg = p.surface },
                },
                separator = pill(),
                color = { bg = p.surface, fg = p.fg },
                padding = { left = 1, right = 1 },
                cond = function()
                  local gs = vim.b.gitsigns_status_dict
                  return gs and (gs.added or 0) + (gs.changed or 0) + (gs.removed or 0) > 0
                end,
              },
            },
            lualine_y = {
              {
                "filename",
                file_status = true,
                path = 0, -- name only; the breadcrumb (winbar) shows the full path
                symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                separator = pill(),
                color = { bg = p.surface, fg = p.blue },
                padding = { left = 1, right = 1 },
              },
            },
            lualine_z = {
              {
                project_name,
                icon = "",
                separator = pill(),
                color = { bg = p.surface, fg = p.mauve },
                padding = { left = 1, right = 1 },
              },
            },
          },
        }
      end

      require("lualine").setup(build_config())

      -- Re-render on colorscheme change (palette is dynamic; transparent bg gets re-applied).
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("LualinePillsRefresh", { clear = true }),
        callback = function()
          transparentize()
          require("lualine").setup(build_config())
        end,
      })
    end,
  },
}
