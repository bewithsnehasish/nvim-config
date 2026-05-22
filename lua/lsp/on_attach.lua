return function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- ── Navigation (snacks.nvim picker for fuzzy, multi-result, preview) ─────
  -- gd: go to definition. If multiple definitions exist, shows a picker.
  vim.keymap.set("n", "gd", function()
    Snacks.picker.lsp_definitions()
  end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

  local function move_to_mouse()
    local mouse = vim.fn.getmousepos()
    if mouse.winid and mouse.winid ~= 0 then
      pcall(vim.api.nvim_set_current_win, mouse.winid)
    end
    if mouse.line > 0 and mouse.column > 0 then
      pcall(vim.api.nvim_win_set_cursor, 0, { mouse.line, mouse.column - 1 })
    end
  end

  vim.keymap.set("n", "<C-LeftMouse>", function()
    move_to_mouse()
    vim.lsp.buf.definition()
  end, vim.tbl_extend("force", opts, { desc = "Ctrl-click definition" }))

  -- gD: go to declaration (e.g. header files in C, interface in TS)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))

  -- gr: show ALL references in a snacks picker with preview
  vim.keymap.set("n", "gr", function()
    Snacks.picker.lsp_references { include_declaration = false }
  end, vim.tbl_extend("force", opts, { desc = "Show references" }))

  vim.keymap.set("n", "<C-RightMouse>", function()
    move_to_mouse()
    Snacks.picker.lsp_references { include_declaration = false }
  end, vim.tbl_extend("force", opts, { desc = "Ctrl-right-click references" }))

  -- gi: implementations (useful for interfaces/abstract classes)
  vim.keymap.set("n", "gi", function()
    Snacks.picker.lsp_implementations()
  end, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))

  -- gt: type definition (e.g. jump from variable to its type declaration)
  vim.keymap.set("n", "gt", function()
    Snacks.picker.lsp_type_definitions()
  end, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

  -- ── Symbols ───────────────────────────────────────────────────────────────
  -- <leader>ls: document symbols (functions, classes, vars in current file)
  vim.keymap.set("n", "<leader>ls", function()
    Snacks.picker.lsp_symbols()
  end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))

  -- <leader>lw: workspace symbols (search symbols across entire project)
  vim.keymap.set("n", "<leader>lw", function()
    Snacks.picker.lsp_workspace_symbols()
  end, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))

  -- ── Code actions ──────────────────────────────────────────────────────────
  vim.keymap.set(
    { "n", "v" },
    "<leader>ca",
    vim.lsp.buf.code_action,
    vim.tbl_extend("force", opts, { desc = "Code action" })
  )

  -- ── Rename ────────────────────────────────────────────────────────────────
  -- NOTE: <leader>rn is handled by inc-rename.nvim (refactoring.lua).
  --       Do NOT set it here — on_attach buffer keymaps would shadow it.

  -- ── Signature & hover ─────────────────────────────────────────────────────
  vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

  -- ── Inlay hints toggle (Neovim 0.10+) ────────────────────────────────────
  vim.keymap.set("n", "<leader>lh", function()
    local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    vim.notify(
      "Inlay hints " .. (enabled and "disabled" or "enabled"),
      vim.log.levels.INFO,
      { title = "LSP", timeout = 1500 }
    )
  end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))

  -- ── Yank diagnostic at cursor to clipboard (no UI, single keystroke) ─────
  vim.keymap.set("n", "<leader>ly", function()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
    if #diags == 0 then
      vim.notify("No diagnostic on this line", vim.log.levels.WARN, { title = "LSP" })
      return
    end
    local lines = {}
    for _, d in ipairs(diags) do
      local src = d.source and (" [" .. d.source .. "]") or ""
      local code = d.code and (" (" .. tostring(d.code) .. ")") or ""
      table.insert(lines, d.message .. src .. code)
    end
    local text = table.concat(lines, "\n")
    vim.fn.setreg("+", text) -- system clipboard
    vim.fn.setreg('"', text) -- default register
    local preview = text:sub(1, 60) .. (#text > 60 and "…" or "")
    vim.notify("Yanked: " .. preview, vim.log.levels.INFO, { title = "LSP", timeout = 1500 })
  end, vim.tbl_extend("force", opts, { desc = "Yank diagnostic(s) at cursor to clipboard" }))

  -- ── LSP management ────────────────────────────────────────────────────────
  vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
  vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>", vim.tbl_extend("force", opts, { desc = "LSP info" }))

  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
end
