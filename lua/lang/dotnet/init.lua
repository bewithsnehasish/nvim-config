local M = {}

function M.setup()
  local on_attach = require "lsp.on_attach"
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local blink_status, blink = pcall(require, "blink.cmp")
  if blink_status then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  local function roslyn_on_attach(client, bufnr)
    on_attach(client, bufnr)

    local opts = { buffer = bufnr, noremap = true, silent = true }

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client.server_capabilities.codeLensProvider then
      vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end

    vim.keymap.set("n", "<leader>lc", function()
      local is_enabled = vim.lsp.codelens.is_enabled { bufnr = bufnr }
      vim.lsp.codelens.enable(not is_enabled, { bufnr = bufnr })
      vim.notify("CodeLens " .. (is_enabled and "disabled" or "enabled"), vim.log.levels.INFO, { title = "LSP" })
    end, { buffer = bufnr, noremap = true, silent = true, desc = "Toggle code lens" })
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
        for bufnr, _ in pairs(client.attached_buffers) do
          if vim.api.nvim_buf_is_valid(bufnr) and vim.lsp.codelens.is_enabled { bufnr = bufnr } then
            vim.lsp.codelens.enable(true, { bufnr = bufnr })
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
        -- "fullSolution" gives solution-wide diagnostics but is heavy on large solutions
        dotnet_analyzer_diagnostics_scope = "openFiles",
        dotnet_compiler_diagnostics_scope = "openFiles",
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

        -- Ensure modifiable is true when writing, then set back to false
        vim.bo[args.buf].modifiable = true
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
