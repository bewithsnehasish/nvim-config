-- lua/plugins/nvim-navic.lua
return {
  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local icons = require("user.icons")

      require("nvim-navic").setup {
        icons = icons.kind,
        highlight = true,
        lsp = {
          auto_attach = true,
        },
        click = true,
        separator = " " .. icons.ui.ChevronRight .. " ",
        depth_limit = 5,
        depth_limit_indicator = "..",
        lazy_update_context = true,
      }
    end,
  },
}
