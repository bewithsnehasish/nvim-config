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
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          -- FIX 4: Added useful filetypes to disable lualine on
          disabled_filetypes = {
            statusline = { "alpha", "dashboard", "lazy", "mason" },
          },
          ignore_focus = { "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },

          -- FIX 5: Filename moved here where it has space and context
          lualine_c = {
            {
              "filename",
              path = 1, -- show relative path (0 = just name, 2 = absolute)
              symbols = {
                modified = " ●", -- unsaved indicator
                readonly = " ",
                unnamed = "[No Name]",
              },
            },
          },

          lualine_x = {
            -- FIX 6: Lazy.nvim pending updates
            {
              lazy_ok and lazy_status.updates or nil,
              cond = lazy_ok and lazy_status.has_updates or nil,
              color = { fg = "#ffaa00" },
            },

            -- FIX 2: copilot is already safe via its own plugin guard
            "copilot",
            "encoding",
            "fileformat",
            "filetype",
          },

          lualine_y = { "progress" },

          -- FIX 5: Removed filename from here, only position info
          lualine_z = { "location" },
        },
        extensions = { "quickfix", "man", "fugitive", "nvim-tree" },
      }
    end,
  },
}
