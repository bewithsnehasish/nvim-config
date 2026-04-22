return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        signs_staged_enable = true,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { follow_files = true },
        attach_to_untracked = true,
        -- Inline blame shown at end-of-line; toggle with <leader>hb
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 600,
          ignore_whitespace = true,
        },
        preview_config = { border = "rounded" },

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr, noremap = true, silent = true }

          -- Navigation: jump between hunks
          vim.keymap.set("n", "]h", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(gs.next_hunk)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Next hunk" }))

          vim.keymap.set("n", "[h", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(gs.prev_hunk)
            return "<Ignore>"
          end, vim.tbl_extend("force", opts, { expr = true, desc = "Prev hunk" }))

          -- Stage / reset individual hunks
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
          vim.keymap.set("v", "<leader>hs", function()
            gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, vim.tbl_extend("force", opts, { desc = "Stage selected hunk" }))
          vim.keymap.set("v", "<leader>hr", function()
            gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, vim.tbl_extend("force", opts, { desc = "Reset selected hunk" }))

          -- Stage / reset entire buffer
          vim.keymap.set("n", "<leader>hS", gs.stage_buffer, vim.tbl_extend("force", opts, { desc = "Stage buffer" }))
          vim.keymap.set("n", "<leader>hR", gs.reset_buffer, vim.tbl_extend("force", opts, { desc = "Reset buffer" }))

          -- Undo last stage
          vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, vim.tbl_extend("force", opts, { desc = "Undo stage hunk" }))

          -- Preview hunk inline
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))

          -- Blame line (inline virtual text toggle)
          vim.keymap.set("n", "<leader>hb", function()
            gs.toggle_current_line_blame()
          end, vim.tbl_extend("force", opts, { desc = "Toggle line blame" }))

          -- Diff current file
          vim.keymap.set("n", "<leader>hd", gs.diffthis, vim.tbl_extend("force", opts, { desc = "Diff this file" }))

          -- Text objects: select hunk in visual/operator mode
          vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", opts)
        end,
      }
    end,
  },
}
