<<<<<<< HEAD
return {
  -- {
  --   "neoclide/coc.nvim",
  --   branch = "release",
  --   build = "yarn install --frozen-lockfile",
  --   event = "VeryLazy",
  --   config = function()
  --     -- Previous keybindings remain the same
  --     vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
  --     vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
  --     vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
  --     vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })
  --
  --     local function show_docs()
  --       local cw = vim.fn.expand "<cword>"
  --       if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
  --         vim.api.nvim_command("h " .. cw)
  --       elseif vim.api.nvim_eval "coc#rpc#ready()" then
  --         vim.fn.CocActionAsync "doHover"
  --       else
  --         vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
  --       end
  --     end
  --     vim.keymap.set("n", "K", show_docs, { silent = true })
  --
  --     -- Modified completion keybindings
  --     local keyset = vim.keymap.set
  --     local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  --
  --     -- Changed from TAB to Ctrl+j for next suggestion
  --     keyset(
  --       "i",
  --       "<C-j>",
  --       'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
  --       opts
  --     )
  --     -- Changed from Shift+TAB to Ctrl+k for previous suggestion
  --     keyset("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
  --
  --     -- Rest of the keybindings remain the same
  --     keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
  --     keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })
  --     keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
  --     keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })
  --     keyset("n", "<C-n>", "<Plug>(coc-cursors-word)", { silent = true })
  --
  --     function _G.check_back_space()
  --       local col = vim.fn.col "." - 1
  --       return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
  --     end
  --
  --     vim.api.nvim_create_autocmd("CursorHold", {
  --       pattern = "*",
  --       callback = function()
  --         vim.fn.CocActionAsync "highlight"
  --       end,
  --     })
  --
  --     vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
  --     vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
  --   end,
  -- },
=======
-- plugins/coc.lua
return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    build = "yarn install --frozen-lockfile",
    event = "VeryLazy", -- lazy load on event
    config = function()
      -- Basic coc.nvim key mappings
      vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
      vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
      vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
      vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })

      -- Use K to show documentation in preview window
      local function show_docs()
        local cw = vim.fn.expand "<cword>"
        if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
          vim.api.nvim_command("h " .. cw)
        elseif vim.api.nvim_eval "coc#rpc#ready()" then
          vim.fn.CocActionAsync "doHover"
        else
          vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
        end
      end
      vim.keymap.set("n", "K", show_docs, { silent = true })

      -- Completion keybindings
      local keyset = vim.keymap.set
      -- Use tab for trigger completion with characters ahead and navigate
      local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
      keyset(
        "i",
        "<TAB>",
        'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
        opts
      )
      keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

      -- Make <CR> to accept selected completion item or notify coc.nvim to format
      keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

      -- Use <c-space> to trigger completion
      keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

      -- Use `[g` and `]g` to navigate diagnostics
      keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
      keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

      -- Multiple cursors support
      keyset("n", "<C-n>", "<Plug>(coc-cursors-word)", { silent = true })

      -- Helper function for tab completion
      function _G.check_back_space()
        local col = vim.fn.col "." - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
      end

      -- Highlight symbol under cursor on CursorHold
      vim.api.nvim_create_autocmd("CursorHold", {
        pattern = "*",
        callback = function()
          vim.fn.CocActionAsync "highlight"
        end,
      })

      -- Add `:Format` command to format current buffer
      vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

      -- Add `:OR` command for organize imports of the current buffer
      vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
    end,
  },
>>>>>>> refs/remotes/origin/main
}
