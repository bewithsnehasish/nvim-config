return {
  "lewis6991/gitsigns.nvim",
  event = "BufEnter",
  cmd = "Gitsigns",
  keys = {
    {
      "<leader>gj",
      function()
        require("gitsigns").next_hunk { navigation_message = false }
      end,
      desc = "Next Hunk",
    },
    {
      "<leader>gk",
      function()
        require("gitsigns").prev_hunk { navigation_message = false }
      end,
      desc = "Prev Hunk",
    },
    {
      "<leader>gp",
      function()
        require("gitsigns").preview_hunk()
      end,
      desc = "Preview Hunk",
    },
    {
      "<leader>gr",
      function()
        require("gitsigns").reset_hunk()
      end,
      desc = "Reset Hunk",
    },
    {
      "<leader>gl",
      function()
        require("gitsigns").blame_line()
      end,
      desc = "Blame",
    },
    {
      "<leader>gR",
      function()
        require("gitsigns").reset_buffer()
      end,
      desc = "Reset Buffer",
    },
    {
      "<leader>gs",
      function()
        require("gitsigns").stage_hunk()
      end,
      desc = "Stage Hunk",
    },
    {
      "<leader>gu",
      function()
        require("gitsigns").undo_stage_hunk()
      end,
      desc = "Undo Stage Hunk",
    },
    { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Git Diff" },
  },
  config = function()
    local icons = require "plugins.user.icons"

    require("gitsigns").setup {
      signs = {
        add = { text = icons.ui.BoldLineMiddle },
        change = { text = icons.ui.BoldLineDashedMiddle },
        delete = { text = icons.ui.TriangleShortArrowRight },
        topdelete = { text = icons.ui.TriangleShortArrowRight },
        changedelete = { text = icons.ui.BoldLineMiddle },
      },
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      update_debounce = 200,
      max_file_length = 40000,
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    }

    -- Define the highlight groups
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#00ff00" }) -- Customize the colors as needed
    vim.api.nvim_set_hl(0, "GitSignsAddLn", { link = "GitSignsAdd" })
    vim.api.nvim_set_hl(0, "GitSignsAddNr", { link = "GitSignsAdd" })

    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ffff00" })
    vim.api.nvim_set_hl(0, "GitSignsChangeLn", { link = "GitSignsChange" })
    vim.api.nvim_set_hl(0, "GitSignsChangeNr", { link = "GitSignsChange" })

    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff0000" })
    vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { link = "GitSignsDelete" })
    vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { link = "GitSignsDelete" })

    vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitSignsDelete" })
    vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { link = "GitSignsDeleteLn" })
    vim.api.nvim_set_hl(0, "GitSignsTopdeleteNr", { link = "GitSignsDeleteNr" })

    vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitSignsChange" })
    vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { link = "GitSignsChangeLn" })
    vim.api.nvim_set_hl(0, "GitSignsChangedeleteNr", { link = "GitSignsChangeNr" })
  end,
}
