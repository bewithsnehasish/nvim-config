-- return {
--   {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--     config = function()
--       require("copilot").setup {
--         panel = {
--           enabled = true,
--           auto_refresh = true,
--           keymap = {
--             jump_prev = "[[",
--             jump_next = "]]",
--             accept = "<CR>",
--             refresh = "gr",
--             open = "<M-CR>",
--           },
--           layout = {
--             position = "bottom", -- options: top, bottom, left, right
--             ratio = 0.4,
--           },
--         },
--         suggestion = {
--           enabled = true,
--           auto_trigger = true,
--           debounce = 75,
--           keymap = {
--             accept = "<C-l>",
--             accept_word = false,
--             accept_line = false,
--             next = "<C-j>",
--             prev = "<C-k>",
--             dismiss = "<C-h>",
--           },
--         },
--         filetypes = {
--           yaml = true,
--           markdown = true,
--           help = false,
--           gitcommit = false,
--           gitrebase = false,
--           hgcommit = false,
--           svn = false,
--           cvs = false,
--           ["*"] = true,
--         },
--         copilot_node_command = "node", -- ensure this is Node 18+ or 22+
--         server_opts_overrides = {},
--       }
--
--       -- Toggle auto suggestions (normal mode)
--       vim.api.nvim_set_keymap(
--         "n",
--         "<C-s>",
--         ":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
--         { noremap = true, silent = true }
--       )
--     end,
--   },
--
--   -- cmp source for GitHub Copilot
--   {
--     "zbirenbaum/copilot-cmp",
--     dependencies = { "zbirenbaum/copilot.lua" },
--     config = function()
--       require("copilot_cmp").setup {
--         method = "getCompletionsCycling",
--         formatters = {
--           insert_text = require("copilot_cmp.format").remove_existing,
--         },
--       }
--     end,
--   },
-- }

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- options: top, bottom, left, right
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          -- IMPORTANT: avoid conflicts with Supermaven keymaps
          keymap = {
            accept = "<C-l>", -- Copilot: accept suggestion
            accept_word = false, -- leave word-accept to Supermaven (<C-j>)
            accept_line = false,
            next = "<C-k>", -- Copilot: next suggestion
            prev = "<C-p>", -- Copilot: previous suggestion
            dismiss = "<C-h>", -- Copilot: dismiss suggestion
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["*"] = true, -- enable for all other filetypes
        },
        copilot_node_command = "node", -- ensure this is Node 22+ ideally
        server_opts_overrides = {},
      }

      -- Toggle Copilot auto suggestions in the current buffer (Normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<C-s>",
        ":lua require('copilot.suggestion').toggle_auto_trigger()<CR>",
        { noremap = true, silent = true }
      )
    end,
  },

  -- cmp source for GitHub Copilot
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup {
        method = "getCompletionsCycling",
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        },
      }
    end,
  },
}
