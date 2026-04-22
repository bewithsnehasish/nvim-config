return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    -- Load on these keys so it's available immediately without a prior :Trouble call
    keys = {
      -- Diagnostics
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                desc = "Workspace diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",   desc = "Buffer diagnostics" },
      -- References & definitions — persistent panel; use alongside gr/gd for quick jumps
      { "<leader>xr", "<cmd>Trouble lsp_references toggle focus=true<cr>",  desc = "References (Trouble)" },
      { "<leader>xd", "<cmd>Trouble lsp_definitions toggle focus=true<cr>", desc = "Definitions (Trouble)" },
      { "<leader>xi", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP info panel" },
      -- Lists
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                     desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                    desc = "Location list" },
    },
    opts = {
      modes = {
        -- Show references without the declaration itself — keeps the list clean
        lsp_references = {
          params = { include_declaration = false },
        },
        -- Right-side panel used for LSP info (<leader>xi)
        lsp = {
          win = { position = "right" },
        },
      },
      -- Open trouble on the same line as cursor when there's only one result
      auto_jump = true,
      -- Don't steal focus when opening via toggle
      focus = false,
    },
  },
}
