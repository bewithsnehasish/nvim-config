return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- U+E0BE (upper-right triangle, left cap) and U+E0B8 (lower-left triangle,
      -- right cap) — Powerline slant glyphs. As PER-COMPONENT caps each must fill
      -- INWARD toward the segment, so both present a "/" hypotenuse and the segment
      -- is a forward-slanting parallelogram. Written as UTF-8 byte escapes; literal
      -- chars get stripped by some editing pipelines.
      local LSLANT = "\xee\x82\xbe"
      local RSLANT = "\xee\x82\xb8"

      local function pill()
        return { left = LSLANT, right = RSLANT }
      end

      -- Subtle bar bg (Catppuccin Mantle) so the statusline reads as a distinct bar,
      -- not blended into the editor. Pills still sit on top with their own colors.
      local BAR_BG = "#181825"
      local function transparentize()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = BAR_BG })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = BAR_BG })
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

      local wakatime_cache = ""

      local function update_wakatime()
        local path = vim.fn.expand "~/.wakatime/today"
        vim.uv.fs_open(path, "r", 438, function(err, fd)
          if err or not fd then
            wakatime_cache = ""
            return
          end
          vim.uv.fs_fstat(fd, function(err_stat, stat)
            if err_stat or not stat or stat.size == 0 then
              vim.uv.fs_close(fd, function() end)
              wakatime_cache = ""
              return
            end
            vim.uv.fs_read(fd, stat.size, 0, function(err_read, data)
              vim.uv.fs_close(fd, function() end)
              if err_read or not data then
                wakatime_cache = ""
                return
              end
              wakatime_cache = data:gsub("[\r\n]", "")
            end)
          end)
        end)
      end

      -- Initial async fetch on startup
      update_wakatime()

      -- Refresh WakaTime cache once every 30 seconds
      local waka_timer = vim.uv.new_timer()
      if waka_timer then
        waka_timer:start(30000, 30000, vim.schedule_wrap(update_wakatime))
      end

      local function wakatime_today()
        return wakatime_cache
      end

      -- Custom Component: Macro Recording State Indicator
      local function macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == "" then
          return ""
        else
          return "󰑋  Recording @" .. recording_register
        end
      end

      -- Custom Component: Current Search count/index (e.g. 1/5)
      local function search_result()
        if vim.v.hlsearch == 0 then
          return ""
        end
        local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
        if not ok or next(result) == nil or result.total == 0 then
          return ""
        end
        return string.format(" %d/%d", result.current, result.total)
      end

      -- Custom Component: Current 24h system time
      local function current_time()
        return " " .. os.date "%R"
      end

      -- Custom Component: Spell check status
      local function spell_status()
        if vim.wo.spell then
          return "󰓆 SPELL"
        end
        return ""
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
                macro_recording,
                icon = "",
                separator = pill(),
                color = { bg = p.red, fg = p.base, gui = "bold" },
                padding = { left = 1, right = 1 },
                cond = function()
                  return macro_recording() ~= ""
                end,
              },
              {
                search_result,
                icon = "",
                separator = pill(),
                color = { bg = p.yellow, fg = p.base, gui = "bold" },
                padding = { left = 1, right = 1 },
                cond = function()
                  return search_result() ~= ""
                end,
              },
              {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                sections = { "error", "warn", "info", "hint" },
                symbols = { error = " ", warn = "⚠ ", info = " ", hint = " " },
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
            lualine_c = {
              {
                "navic",
                color_correction = "dynamic",
              },
            },
            lualine_x = {
              {
                spell_status,
                icon = "",
                separator = pill(),
                color = { bg = p.surface, fg = p.yellow },
                padding = { left = 1, right = 1 },
                cond = function()
                  return spell_status() ~= ""
                end,
              },
              {
                "branch",
                icon = "",
                separator = pill(),
                color = { bg = p.surface, fg = p.mauve },
                padding = { left = 1, right = 1 },
              },
              {
                "diff",
                symbols = { added = " ", modified = "󰏬 ", removed = " " },
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
                path = 1,
                symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                separator = pill(),
                color = { bg = p.surface, fg = p.blue },
                padding = { left = 1, right = 1 },
              },
            },
            lualine_z = {
              {
                project_name,
                icon = "󰉋",
                separator = pill(),
                color = { bg = p.surface, fg = p.mauve },
                padding = { left = 1, right = 1 },
              },
              {
                current_time,
                separator = pill(),
                color = { bg = p.surface, fg = p.lavender },
                padding = { left = 1, right = 1 },
              },
            },
          },
        }
      end

      require("lualine").setup(build_config())

      -- Autocommands to refresh lualine instantly when macro recording starts/stops
      vim.api.nvim_create_autocmd("RecordingEnter", {
        group = vim.api.nvim_create_augroup("LualineMacroRefresh", { clear = true }),
        pattern = "*",
        callback = function()
          require("lualine").refresh { place = { "statusline" } }
        end,
      })
      vim.api.nvim_create_autocmd("RecordingLeave", {
        group = vim.api.nvim_create_augroup("LualineMacroRefreshLeave", { clear = true }),
        pattern = "*",
        callback = function()
          local timer = vim.uv.new_timer()
          if timer then
            timer:start(
              50,
              0,
              vim.schedule_wrap(function()
                require("lualine").refresh { place = { "statusline" } }
              end)
            )
          end
        end,
      })

      vim.api.nvim_create_autocmd("OptionSet", {
        group = vim.api.nvim_create_augroup("LualineSpellRefresh", { clear = true }),
        pattern = "spell",
        callback = function()
          require("lualine").refresh { place = { "statusline" } }
        end,
      })

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
