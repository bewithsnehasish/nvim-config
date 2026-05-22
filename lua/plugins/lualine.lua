return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- U+E0B6 (round left) and U+E0B4 (round right) — Powerline glyphs.
      -- Written as UTF-8 byte escapes; literal chars get stripped by some editing pipelines.
      local LROUND = "\xee\x82\xb6"
      local RROUND = "\xee\x82\xb4"

      local function pill()
        return { left = LROUND, right = RROUND }
      end

      local function transparentize()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
      end
      transparentize()

      -- Catppuccin Mocha palette — hardcoded so pills look identical across colorschemes
      local p = {
        base = "#1e1e2e",
        surface = "#313244",
        fg = "#cdd6f4",
        green = "#a6e3a1",
        yellow = "#f9e2af",
        red = "#f38ba8",
        blue = "#89b4fa",
        mauve = "#cba6f7",
        sky = "#89dceb",
        peach = "#fab387",
        lavender = "#b4befe",
      }

      local function mode_pill_color()
        local m = vim.api.nvim_get_mode().mode
        local map = {
          n = p.green,
          i = p.blue,
          v = p.mauve,
          V = p.mauve,
          ["\22"] = p.mauve,
          s = p.mauve,
          S = p.mauve,
          c = p.peach,
          R = p.red,
          r = p.red,
          t = p.sky,
        }
        return { bg = map[m] or map[m:sub(1, 1)] or p.green, fg = p.base, gui = "bold" }
      end

      local function project_name()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end

      local function wakatime_today()
        local f = io.open(vim.fn.expand "~/.wakatime/today", "r")
        if not f then
          return ""
        end
        local s = f:read "*a" or ""
        f:close()
        return (s:gsub("[\r\n]", ""))
      end

      local function build_config()
        return {
          options = {
            icons_enabled = true,
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
            component_separators = "",
            section_separators = "",
            disabled_filetypes = {
              statusline = { "alpha", "dashboard", "lazy", "mason", "neo-tree" },
            },
            globalstatus = true,
          },
          sections = {
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
                path = 0,
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
