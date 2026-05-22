-- return {
--   {
--     "nvim-lualine/lualine.nvim",
--     event = "VeryLazy",
--     dependencies = { "nvim-tree/nvim-web-devicons", "AndreM222/copilot-lualine" },
--     config = function()
--       require("nvim-web-devicons").setup() -- Ensure web-devicons is set up
--
--       require("lualine").setup({
--         options = {
--           icons_enabled = true,
--           theme = "horizon",
--           component_separators = { left = "", right = "" },
--           section_separators = { left = "", right = "" },
--           disabled_filetypes = {},
--           ignore_focus = { "NvimTree" },
--         },
--         sections = {
--           lualine_a = { "mode" },
--           lualine_b = { "branch", "diff", "diagnostics" },
--           lualine_c = {},
--           lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
--           lualine_y = { "progress" },
--           lualine_z = { "location", "filename" }, -- Add filename here
--         },
--         extensions = { "quickfix", "man", "fugitive" },
--       })
--     end,
--   },
-- }
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "AndreM222/copilot-lualine",
    },
    config = function()
      -- Safe load for lazy updates badge
      local lazy_ok, lazy_status = pcall(require, "lazy.status")

      require("lualine").setup {
        options = {
          icons_enabled = true,
          theme = "horizon",
          -- Powerline glyphs (Nerd Font required):
          --   \xee\x82\xb7 = U+E0B7 (thin round left, component divider)
          --   \xee\x82\xb5 = U+E0B5 (thin round right, component divider)
          --   \xee\x82\xb6 = U+E0B6 (full round left, section transition)
          --   \xee\x82\xb4 = U+E0B4 (full round right, section transition)
          component_separators = { left = "\xee\x82\xb7", right = "\xee\x82\xb5" },
          section_separators = { left = "\xee\x82\xb6", right = "\xee\x82\xb4" },
          disabled_filetypes = {
            statusline = { "alpha", "dashboard", "lazy", "mason" },
          },
          ignore_focus = { "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },

          lualine_c = {
            {
              "filename",
              path = 1, -- 0 = name only, 1 = relative, 2 = absolute
              symbols = {
                modified = " ●",
                readonly = " ",
                unnamed = "[No Name]",
              },
            },
          },

          lualine_x = {
            -- Lazy.nvim pending updates badge
            {
              lazy_ok and lazy_status.updates or nil,
              cond = lazy_ok and lazy_status.has_updates or nil,
              color = { fg = "#ffaa00" },
            },
            "copilot",
            "encoding",
            "fileformat",
            "filetype",
          },

          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "quickfix", "man", "fugitive", "nvim-tree" },
      }
    end,
  },
}
