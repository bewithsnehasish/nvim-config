local M = {}

function M.setup()
  vim.filetype.add {
    pattern = {
      [".*%.razor"] = "razor",
      [".*%.cshtml"] = "cshtml",
    },
  }

  local on_attach = require "lsp.on_attach"
  local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = cmp_nvim_lsp_ok
      and cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
    or vim.lsp.protocol.make_client_capabilities()

  local function roslyn_on_attach(client, bufnr)
    on_attach(client, bufnr)

    local opts = { buffer = bufnr, noremap = true, silent = true }

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client.server_capabilities.codeLensProvider then
      vim.lsp.codelens.enable(true, { bufnr = bufnr })

      -- Refresh CodeLens when entering buffer, leaving insert mode, or stopping cursor movement
      local codelens_group = vim.api.nvim_create_augroup("RoslynCodeLensRefresh_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
        buffer = bufnr,
        group = codelens_group,
        callback = function()
          if vim.api.nvim_buf_is_valid(bufnr) and vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end
        end,
      })

      -- Initial deferred refresh after LSP attaches, ensuring CodeLens pulls after initial workspace load
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) and vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
          vim.lsp.codelens.refresh({ bufnr = bufnr })
        end
      end, 2000)
    end

    vim.keymap.set(
      "n",
      "<leader>lc",
      function()
        local is_enabled = vim.lsp.codelens.is_enabled({ bufnr = bufnr })
        vim.lsp.codelens.enable(not is_enabled, { bufnr = bufnr })
        if not is_enabled then
          vim.lsp.codelens.refresh({ bufnr = bufnr })
        end
        vim.notify(
          "CodeLens " .. (is_enabled and "disabled" or "enabled"),
          vim.log.levels.INFO,
          { title = "LSP" }
        )
      end,
      { buffer = bufnr, noremap = true, silent = true, desc = "Toggle code lens" }
    )
  end

  -- Global autocmd to refresh CodeLens when the Roslyn server finishes loading/indexing the project
  vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("RoslynCodeLensLspProgress", { clear = true }),
    callback = function(ev)
      local data = ev.data
      if not data or not data.params or not data.params.value then
        return
      end
      local client = vim.lsp.get_client_by_id(data.client_id)
      if client and client.name == "roslyn" and data.params.value.kind == "end" then
        for _, bufnr in ipairs(vim.lsp.get_buffers_by_client_id(data.client_id)) do
          if vim.api.nvim_buf_is_valid(bufnr) and vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end
        end
      end
    end,
  })

  vim.lsp.config("roslyn", {
    capabilities = capabilities,
    on_attach = roslyn_on_attach,
    settings = {
      ["csharp|background_analysis"] = {
        -- fullSolution enables Roslyn to index the whole solution for cross-file references/definitions
        dotnet_analyzer_diagnostics_scope = "fullSolution",
        dotnet_compiler_diagnostics_scope = "fullSolution",
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
        dotnet_enable_tests_code_lens = true,
      },
      ["csharp|completion"] = {
        dotnet_show_completion_items_from_unimported_namespaces = true,
        dotnet_show_name_completion_suggestions = true,
      },
      ["csharp|formatting"] = {
        dotnet_organize_imports_on_format = true,
      },
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        dotnet_enable_inlay_hints_for_other_parameters = true,
        dotnet_enable_inlay_hints_for_parameters = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      },
      ["csharp|symbol_search"] = {
        dotnet_search_reference_assemblies = true,
      },
    },
  })

  require("roslyn").setup {
    filewatching = "roslyn",
    broad_search = false,
    lock_target = false,
    silent = true,
  }

  -- Autocommand to handle virtual csharp:/ and csharp:// documents from Roslyn LSP
  local csharp_metadata_group = vim.api.nvim_create_augroup("RoslynCsharpMetadata", { clear = true })
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = csharp_metadata_group,
    pattern = { "csharp:/*", "csharp://*" },
    callback = function(args)
      local uri = args.match
      vim.bo[args.buf].modifiable = true
      vim.bo[args.buf].swapfile = false
      vim.bo[args.buf].filetype = "cs"

      -- Find active Roslyn client
      local client = vim.lsp.get_clients({ name = "roslyn" })[1]
      if not client then
        vim.notify("No active Roslyn LSP client found to load metadata", vim.log.levels.ERROR, { title = "Roslyn LSP" })
        return
      end

      local content
      client:request("workspace/textDocumentContent", { uri = uri }, function(err, result)
        if err then
          vim.notify("Failed to load C# metadata: " .. tostring(err), vim.log.levels.ERROR, { title = "Roslyn LSP" })
          content = ""
          return
        end
        content = result and result.text or ""
        local normalized = string.gsub(content, "\r\n", "\n")
        local lines = vim.split(normalized, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
        vim.bo[args.buf].modifiable = false
        vim.bo[args.buf].modified = false
      end, args.buf)

      -- Block up to 2 seconds for LSP response so cursor positioning works correctly
      vim.wait(2000, function()
        return content ~= nil
      end)
    end,
  })
end

return M
