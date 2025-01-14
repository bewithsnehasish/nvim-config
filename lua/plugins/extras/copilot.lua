return {
  -- "zbirenbaum/copilot.lua",
  -- cmd = "Copilot",
  -- event = "InsertEnter",
  -- dependencies = {
  --   "zbirenbaum/copilot-cmp",
  -- },
  -- config = function()
  --   require("copilot").setup {
  --     panel = {
  --       enabled = true,
  --       auto_refresh = true,
  --       keymap = {
  --         jump_prev = "[[",
  --         jump_next = "]]",
  --         accept = "<CR>",
  --         refresh = "gr",
  --         open = "<M-CR>",
  --       },
  --       layout = {
  --         position = "bottom", -- can be "top", "bottom", "left", "right"
  --         ratio = 0.4,
  --       },
  --     },
  --     suggestion = {
  --       enabled = true,
  --       auto_trigger = true,
  --       debounce = 75,
  --       keymap = {
  --         accept = "<C-l>",
  --         accept_word = false,
  --         accept_line = false,
  --         next = "<C-j>",
  --         prev = "<C-k>",
  --         dismiss = "<C-h>",
  --       },
  --     },
  --     filetypes = {
  --       yaml = true,
  --       markdown = true,
  --       help = false,
  --       gitcommit = false,
  --       gitrebase = false,
  --       hgcommit = false,
  --       svn = false,
  --       cvs = false,
  --       ["."] = false,
  --     },
  --     copilot_node_command = "node", -- Node.js version must be > 16.x
  --     server_opts_overrides = {},
  --   }
  --
  --   local opts = { noremap = true, silent = true }
  --   vim.api.nvim_set_keymap("n", "<c-s>", ":lua require('copilot.suggestion').toggle_auto_trigger()<CR>", opts)
  --
  --   require("copilot_cmp").setup {
  --     method = "getCompletionsCycling",
  --     formatters = {
  --       insert_text = require("copilot_cmp.format").remove_existing,
  --     },
  --   }
  -- end,
}
