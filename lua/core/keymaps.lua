vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

-- Move line up
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("i", "<M-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Move line down
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("i", "<M-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Delete word backward in insert mode
vim.keymap.set("i", "<C-b>", "<C-o>db", { desc = "Delete word backward", silent = true })

-- Word wrap toggle
vim.keymap.set("n", "<leader>wr", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle word wrap", silent = true })

-- Paste from system clipboard
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard", silent = true })
vim.keymap.set("i", "<C-v>", "<C-R>+", { desc = "Paste from system clipboard", silent = true })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste selection from system clipboard", silent = true })

-- DAP keymaps live in plugins/debugging.lua — duplicating them here overwrites lazy's key handlers

-- Buffer & Tab Navigation (Bufferline)
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous buffer", silent = true })

vim.keymap.set("n", "<leader>X", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all OTHER buffers", silent = true })

vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin/Unpin current buffer", silent = true })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer by letter", silent = true })

vim.keymap.set("n", "<leader>c", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>c", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>cc", '"+yy', { desc = "Copy line to system clipboard" })

-- ── Diagnostics ─────────────────────────────────────────────────────────────
-- Global, not buffer-local: vim.diagnostic needs no LSP client (linters, DAP and
-- other producers publish here too), and buffer-local maps silently disappear in
-- buffers where no server attached.

-- <leader>ld: interactive (focusable) diagnostic float — <C-y> yanks, <Esc>/<CR> closes
vim.keymap.set("n", "<leader>ld", function()
  local winid = vim.fn.win_getid()
  local float_bufnr, float_winid = vim.diagnostic.open_float(nil, {
    scope = "cursor",
    focusable = true,
    close_events = {},
    border = "rounded",
    source = "if_many",
    format = function(d)
      return d.message .. (d.source and (" [" .. d.source .. "]") or "")
    end,
  })

  if not float_winid then
    vim.notify("No diagnostics at cursor", vim.log.levels.WARN, { title = "Diagnostics" })
    return
  end

  vim.fn.win_gotoid(float_winid)

  local function back()
    vim.api.nvim_win_close(float_winid, true)
    vim.fn.win_gotoid(winid)
  end

  vim.keymap.set("n", "<C-y>", function()
    vim.cmd "normal! ggVGy"
    vim.notify("Diagnostic text yanked!", vim.log.levels.INFO, { title = "Yank" })
  end, { buffer = float_bufnr, nowait = true })
  vim.keymap.set("n", "<Esc>", back, { buffer = float_bufnr, nowait = true })
  vim.keymap.set("n", "<CR>", back, { buffer = float_bufnr, nowait = true })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(float_winid),
    once = true,
    callback = function()
      vim.fn.win_gotoid(winid)
    end,
  })
end, { desc = "Interactive diagnostic float" })

-- <leader>ly: yank diagnostic(s) on current line to clipboard
vim.keymap.set("n", "<leader>ly", function()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = lnum })
  if #diags == 0 then
    vim.notify("No diagnostic on this line", vim.log.levels.WARN, { title = "Diagnostics" })
    return
  end
  local lines = {}
  for _, d in ipairs(diags) do
    local src = d.source and (" [" .. d.source .. "]") or ""
    local code = d.code and (" (" .. tostring(d.code) .. ")") or ""
    table.insert(lines, d.message .. src .. code)
  end
  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify(
    "Yanked: " .. text:sub(1, 60) .. (#text > 60 and "…" or ""),
    vim.log.levels.INFO,
    { title = "Diagnostics", timeout = 1500 }
  )
end, { desc = "Yank diagnostic(s) at cursor to clipboard" })

-- <leader>lD: raw diagnostic inspector
vim.keymap.set("n", "<leader>lD", function()
  local diags = vim.diagnostic.get(0)
  print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
end, { desc = "Inspect raw diagnostics" })

-- NOTE: no ]d/[d maps here. Nvim 0.12 creates ]d [d ]D [D and <C-w>d unconditionally
-- (:h diagnostic-defaults). The peek-float-on-arrival behaviour is attached via
-- `jump.on_jump` in plugins/lspconfig.lua, which covers all four motions at once.

-- Auto-hover on CursorHold (non-interactive quick glance; updatetime in core/options.lua)
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("DiagnosticsHover", { clear = true }),
  callback = function()
    -- don't fight an already-open float (e.g. the focusable <leader>ld one)
    if vim.b.diagnostics_float_open then
      return
    end
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    if #vim.diagnostic.get(0, { lnum = lnum }) > 0 then
      vim.diagnostic.open_float(nil, {
        scope = "line",
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "if_many",
      })
    end
  end,
})

-- Copy current active file path
vim.keymap.set("n", "yp", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path and path ~= "" then
    vim.fn.setreg("+", path)
    vim.notify("Copied active file path: " .. path, vim.log.levels.INFO, { title = "Clipboard" })
  else
    vim.notify("No active file open", vim.log.levels.WARN, { title = "Clipboard" })
  end
end, { desc = "Copy active file path", silent = true })
