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
    opts = {
      modes = {
        lsp_references = { params = { include_declaration = false } },
        lsp = { win = { position = "right" } },
      },
      auto_jump = true,
      focus = false,
    },
  },
}
