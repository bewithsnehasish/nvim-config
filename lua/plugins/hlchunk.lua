-- return {
--   "shellRaining/hlchunk.nvim",
--   event = { "UIEnter" },
--   config = function()
--     require("hlchunk").setup {
--       chunk = {
--         enable = true,
--         use_treesitter = true,
--         notify = false, -- set to false to disable notifications
--         chars = {
--           horizontal_line = "─",
--           vertical_line = "│",
--           left_top = "╭",
--           left_bottom = "╰",
--           right_arrow = ">",
--         },
--         style = {
--           { fg = "#806d9c" },
--         },
--       },
--       indent = {
--         enable = true,
--         use_treesitter = true,
--         chars = {
--           "│",
--         },
--         style = {
--           { fg = "#2D3640" },
--         },
--       },
--       line_num = {
--         enable = true,
--         use_treesitter = true,
--         style = "#806d9c",
--       },
--       blank = {
--         enable = true,
--         chars = {
--           "․",
--         },
--         style = {
--           { fg = "#2D3640" },
--         },
--       },
--     }
--   end,
-- }

return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local status, hlchunk = pcall(require, "hlchunk")
      if not status then
        vim.notify(
          "Failed to load hlchunk.nvim",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Hlchunk Error", icon = "❌" }
        )
        return
      end

      hlchunk.setup {
        chunk = {
          enable = true,
          use_treesitter = true,
          notify = false,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          style = {
            { fg = "#569cd6" }, -- Match your UI aesthetic
          },
          exclude_filetypes = {
            ["neo-tree"] = true,
            htmldjango = true, -- Prevent errors in Django templates
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        indent = {
          enable = true,
          use_treesitter = false, -- Disable Treesitter indent to prevent errors
          chars = {
            "│",
          },
          style = {
            { fg = "#2D3640" },
          },
          exclude_filetypes = {
            ["neo-tree"] = true,
            htmldjango = true, -- Prevent errors in Django templates
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        line_num = {
          enable = true,
          use_treesitter = true,
          style = "#569cd6", -- Match your UI aesthetic
          exclude_filetypes = {
            ["neo-tree"] = true,
            htmldjango = true, -- Prevent errors in Django templates
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        blank = {
          enable = true,
          chars = {
            "․",
          },
          style = {
            { fg = "#2D3640" },
          },
          exclude_filetypes = {
            ["neo-tree"] = true,
            htmldjango = true, -- Prevent errors in Django templates
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
      }

      -- Disable hlchunk for non-code buffers and problematic filetypes
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI" }, {
        group = vim.api.nvim_create_augroup("HlchunkDisable", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local ft = vim.bo[bufnr].filetype
          local bt = vim.bo[bufnr].buftype
          if
            vim.tbl_contains({ "neo-tree", "htmldjango", "terminal", "help", "", "nofile", "prompt", "quickfix" }, ft)
            or bt ~= ""
          then
            vim.b[bufnr].hlchunk_disabled = true
          end
        end,
      })

      -- Validate Treesitter parser for supported filetypes
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("HlchunkValidate", { clear = true }),
        pattern = {
          "*.js",
          "*.ts",
          "*.jsx",
          "*.tsx",
          "*.svelte",
          "*.html",
          "*.css",
          "*.lua",
          "*.py",
          "*.java",
          "*.php",
        },
        callback = function(ev)
          local bufnr = ev.buf
          local ft = vim.bo[bufnr].filetype
          if not vim.treesitter.language.get_lang(ft) then
            vim.b[bufnr].hlchunk_disabled = true
            vim.notify(
              "No Treesitter parser for " .. ft,
              vim.log.levels.WARN,
              { timeout = 2000, title = "Hlchunk Warning", icon = "⚠️" }
            )
          end
        end,
      })

      -- Explicitly disable hlchunk for htmldjango buffers
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("HlchunkHtmldjangoExclude", { clear = true }),
        pattern = "htmldjango",
        callback = function(ev)
          vim.b[ev.buf].hlchunk_disabled = true
        end,
      })
    end,
  },
}
