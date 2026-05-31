return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>", desc = "Workspace diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>", desc = "Buffer diagnostics" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle focus=true<cr>", desc = "References (Trouble)" },
      { "<leader>xd", "<cmd>Trouble lsp_definitions toggle focus=true<cr>", desc = "Definitions (Trouble)" },
      { "<leader>xi", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP info panel" },
      { "<leader>xq", "<cmd>Trouble qflist toggle focus=true<cr>", desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle focus=true<cr>", desc = "Location list" },
    },
    opts = function()
      local icons = require("user.icons")
      return {
        auto_jump = true,
        focus = true,
        -- Premium layout configuration using custom Nerd Font characters
        icons = {
          indent = {
            top = "│ ",
            middle = "├╴",
            last = "└╴",
            fold_open = " ",
            fold_closed = " ",
            ws = "  ",
          },
          folder_closed = icons.ui.Folder .. " ",
          folder_open = icons.ui.FolderOpen .. " ",
          kinds = icons.kind,
        },
        modes = {
          lsp_references = { 
            params = { include_declaration = false },
            win = { position = "bottom", size = 12 }
          },
          lsp = { 
            win = { position = "right", size = 0.3 } 
          },
          diagnostics = {
            win = { position = "bottom", size = 12 }
          }
        },
      }
    end,
  },
}
