return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "AndreM222/copilot-lualine" },
    config = function()
      require("nvim-web-devicons").setup() -- Ensure web-devicons is set up

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "horizon",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {},
          ignore_focus = { "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {},
          lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location", "filename" }, -- Add filename here
        },
        extensions = { "quickfix", "man", "fugitive" },
      })
    end,
  },
}
