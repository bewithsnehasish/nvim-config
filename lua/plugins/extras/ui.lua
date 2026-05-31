return {
  {
    "lukas-reineke/virt-column.nvim",
    opts = {
      char = { "┆" },
      virtcolumn = "130",
      highlight = { "NonText" },
    },
  },
  {
    "folke/noice.nvim",
    enabled = false,
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = {
          winblend = 0,
          border = "rounded",
        },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 500,
      render = "compact",
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.25)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },
  -- filename
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = "#303270", guifg = "#a9b1d6" },
            InclineNormalNC = { guibg = "none", guifg = "#a9b1d6" },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[*]" .. filename
          end

          local icon, color = devicons.get_icon_color(filename)

          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    config = function(_, opts)
      local icons = require("user.icons")

      -- Fetch cyberdream colors or use default fallback palette
      local c = {
        bg = "#16181a",
        bg_alt = "#1e2124",
        bg_highlight = "#3c4048",
        blue = "#5ea1ff",
        cyan = "#5ef1ff",
        fg = "#ffffff",
        green = "#5eff6c",
        grey = "#7b8496",
        purple = "#bd5eff",
        red = "#ff6e5e",
        yellow = "#f1ff5e"
      }
      local ok, cyberdream_colors = pcall(require, "cyberdream.colors")
      if ok then
        c = cyberdream_colors.default
      end

      -- Define custom error highlight group for the custom areas on the right
      vim.api.nvim_set_hl(0, "BufferLineRightError", { fg = c.red, bold = true })

      -- Inject custom highlights for a stunning UI matching Nvim.png
      opts.highlights = {
        -- Selected (Active) Buffer: italicized, bold, and colored red
        buffer_selected = {
          fg = c.red,
          bold = true,
          italic = true,
        },
        
        -- Active indicator (vibrant cyan vertical line on the left)
        indicator_selected = { fg = c.cyan },
        
        -- Bold & italic diagnostics on the active tab
        error_selected = { fg = c.red, bold = true, italic = true },
        warning_selected = { fg = c.yellow, bold = true, italic = true },
        info_selected = { fg = c.blue, bold = true, italic = true },
        hint_selected = { fg = c.cyan, bold = true, italic = true },
      }

      -- Cache the global error count to prevent expensive global scans on redraw
      local error_count = 0
      local function update_errors()
        local seve = vim.diagnostic.severity
        if seve and seve.ERROR then
          error_count = #vim.diagnostic.get(nil, { severity = seve.ERROR })
        end
      end
      update_errors()

      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = vim.api.nvim_create_augroup("BufferLineErrorCache", { clear = true }),
        callback = update_errors,
      })

      -- Bind options custom_areas to use the cached value
      opts.options.custom_areas = {
        right = function()
          local result = {}
          if error_count > 0 then
            table.insert(result, { text = " " .. icons.diagnostics.Error .. " " .. error_count .. " ", highlight = "BufferLineRightError" })
          end
          return result
        end,
      }

      -- Bind diagnostics_indicator to use the cached icons module
      opts.options.diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local s = ""
        if diagnostics_dict.error and diagnostics_dict.error > 0 then
          s = " " .. icons.diagnostics.Error .. " " .. diagnostics_dict.error
        end
        return s
      end

      require("bufferline").setup(opts)
    end,
    opts = {
      options = {
        mode = "buffers",
        numbers = function(opts)
          local current_buf = vim.api.nvim_get_current_buf()
          if opts.id == current_buf then
            return tostring(opts.id) .. " "
          end
          return ""
        end,
        always_show_bufferline = true,
        auto_toggle_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        buffer_close_icon = "✕",
        close_command = function(bufnr)
          if pcall(require, "snacks") then
            Snacks.bufdelete(bufnr)
          else
            vim.cmd("bdelete " .. bufnr)
          end
        end,
        right_mouse_command = function(bufnr)
          if pcall(require, "snacks") then
            Snacks.bufdelete(bufnr)
          else
            vim.cmd("bdelete " .. bufnr)
          end
        end,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        separator_style = "slant",
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "File Explorer",
            text_align = "right",
            separator = true,
          },
        },
      },
    },
  },
}
