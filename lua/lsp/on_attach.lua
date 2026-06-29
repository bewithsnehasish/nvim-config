return function(client, bufnr)
  -- ── Formatting Integration (conform.nvim) ──────────────────────────────────
  -- Disable formatting if conform.nvim has a formatter for this buffer
  local conform_status, conform = pcall(require, "conform")
  if conform_status then
    local formatters = conform.list_formatters(bufnr)
    if formatters and #formatters > 0 then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end

  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- ── Navigation (Smart Definition Jumps) ───────────────────────────────────
  local function is_import_or_using_line(line)
    if not line then return false end
    local trimmed = string.gsub(line, "^%s+", "")
    return string.match(trimmed, "^import%s")
      or string.match(trimmed, "^using%s")
      or string.match(trimmed, "^include%s")
      or string.match(trimmed, "require%s*%(") ~= nil
  end

  local function smart_definition()
    vim.lsp.buf.definition({
      on_list = function(options)
        local items = options.items
        if not items or #items == 0 then
          vim.notify("No definition found", vim.log.levels.WARN, { title = "LSP" })
          return
        end

        -- Deduplicate items (same file, line, and column)
        local seen = {}
        local unique_items = {}
        for _, item in ipairs(items) do
          local key = string.format("%s:%d:%d", item.filename, item.lnum, item.col)
          if not seen[key] then
            seen[key] = true
            table.insert(unique_items, item)
          end
        end

        -- If multiple locations, filter out import/using statements in the current file
        if #unique_items > 1 then
          local current_file = vim.api.nvim_buf_get_name(0)
          local filtered = {}
          for _, item in ipairs(unique_items) do
            local is_import = false
            if item.filename == current_file then
              local line_content = vim.api.nvim_buf_get_lines(0, item.lnum - 1, item.lnum, false)[1]
              if is_import_or_using_line(line_content) then
                is_import = true
              end
            end
            if not is_import then
              table.insert(filtered, item)
            end
          end
          if #filtered > 0 then
            unique_items = filtered
          end
        end

        -- If multiple locations, and some are declaration files (.d.ts) while others are source files,
        -- filter out the .d.ts files to prefer actual implementation.
        if #unique_items > 1 then
          local has_source = false
          for _, item in ipairs(unique_items) do
            if not string.match(item.filename, "%.d%.ts$") then
              has_source = true
              break
            end
          end
          if has_source then
            local filtered = {}
            for _, item in ipairs(unique_items) do
              if not string.match(item.filename, "%.d%.ts$") then
                table.insert(filtered, item)
              end
            end
            if #filtered > 0 then
              unique_items = filtered
            end
          end
        end

        -- Jump directly if exactly 1 location remains
        if #unique_items == 1 then
          local item = unique_items[1]
          if item.user_data then
            vim.lsp.util.show_document(item.user_data, "utf-8", { focus = true })
          else
            vim.cmd("normal! m'")
            vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
            vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
          end
          return
        end

        -- If multiple locations still remain, open in Snacks picker
        local snacks_items = {}
        for _, item in ipairs(unique_items) do
          table.insert(snacks_items, {
            text = item.text or (vim.fs.basename(item.filename) .. ":" .. item.lnum),
            file = item.filename,
            pos = { item.lnum, item.col - 1 },
          })
        end

        Snacks.picker.pick({
          title = "LSP Definitions",
          items = snacks_items,
          layout = { preset = "vertical" },
          format = "file",
        })
      end
    })
  end

  -- gd: go to definition. Jumps directly if single result (bypassing import/using lines & type declaration files).
  vim.keymap.set("n", "gd", smart_definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

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
    smart_definition()
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

  -- ── LSP management (Neovim 0.12 native commands) ──────────────────────────
  vim.keymap.set("n", "<leader>lr", "<cmd>lsp restart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
  vim.keymap.set("n", "<leader>li", "<cmd>checkhealth vim.lsp<CR>", vim.tbl_extend("force", opts, { desc = "LSP info" }))
  vim.keymap.set("n", "<leader>lq", "<cmd>lsp stop<CR>", vim.tbl_extend("force", opts, { desc = "Stop LSP" }))
  vim.keymap.set("n", "<leader>lS", "<cmd>lsp enable<CR>", vim.tbl_extend("force", opts, { desc = "Start LSP" }))
  vim.keymap.set("n", "<leader>lL", function()
    local log_path = vim.lsp.log.get_filename()
    vim.cmd("tabnew " .. log_path)
  end, vim.tbl_extend("force", opts, { desc = "Open LSP log" }))


  -- ── Interactive Diagnostic Float ──────────────────────────────────────────
  vim.keymap.set("n", "<leader>ld", function()
    local winid = vim.fn.win_getid()
    local float_opts = {
      scope = "cursor",
      focusable = true,
      close_events = {},
      border = "rounded",
      source = "if_many",
      format = function(diagnostic)
        local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
        return string.format("%s%s", diagnostic.message, source)
      end,
    }

    local float_bufnr, float_winid = vim.diagnostic.open_float(nil, float_opts)

    if float_winid then
      -- Focus float first, then set keymaps directly.
      vim.fn.win_gotoid(float_winid)

      vim.keymap.set("n", "<C-y>", function()
        vim.cmd "normal! ggVGy"
        vim.notify("Diagnostic text yanked!", vim.log.levels.INFO, { title = "Yank" })
      end, { buffer = float_bufnr, nowait = true })

      vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_win_close(float_winid, true)
        vim.fn.win_gotoid(winid)
      end, { buffer = float_bufnr, nowait = true })

      vim.keymap.set("n", "<CR>", function()
        vim.api.nvim_win_close(float_winid, true)
        vim.fn.win_gotoid(winid)
      end, { buffer = float_bufnr, nowait = true })

      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(float_winid),
        once = true,
        callback = function()
          vim.fn.win_gotoid(winid)
        end,
      })
    else
      vim.notify("No diagnostics at cursor", vim.log.levels.WARN)
    end
  end, vim.tbl_extend("force", opts, { desc = "Interactive diagnostic float" }))

  -- ── Jump Diagnostics ──────────────────────────────────────────────────────
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump { count = 1 }
    vim.diagnostic.open_float(nil, { focusable = false })
  end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump { count = -1 }
    vim.diagnostic.open_float(nil, { focusable = false })
  end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))

  -- Raw diagnostic inspector
  vim.keymap.set("n", "<leader>lD", function()
    local diags = vim.diagnostic.get(bufnr)
    print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
  end, vim.tbl_extend("force", opts, { desc = "Inspect raw diagnostics" }))

  -- ── Auto-hover Diagnostics on CursorHold (non-interactive, quick glance) ──
  local hover_group = vim.api.nvim_create_augroup("LspDiagnosticsHover_" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    group = hover_group,
    callback = function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
      local diags = vim.diagnostic.get(bufnr, { lnum = cursor_line })
      if #diags > 0 then
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

  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
end
