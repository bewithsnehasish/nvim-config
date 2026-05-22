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

    vim.keymap.set("n", "<leader>ld", function()
      local _, winid = vim.diagnostic.open_float(nil, {
        scope = "cursor",
        focusable = true,
        close_events = {},
        border = "rounded",
        source = "if_many",
      })
      if winid then
        vim.api.nvim_set_current_win(winid)
      end
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump { count = 1, float = true }
    end, opts)
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump { count = -1, float = true }
    end, opts)
    vim.keymap.set("n", "<leader>lD", function()
      local diags = vim.diagnostic.get(bufnr)
      print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
    end, opts)

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client.server_capabilities.codeLensProvider then
      local group = vim.api.nvim_create_augroup("RoslynCodeLens" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.codelens.refresh,
      })
      -- Roslyn needs ~4s to index before codelens data is available
      vim.defer_fn(vim.lsp.codelens.refresh, 4000)
    end

    vim.keymap.set(
      "n",
      "<leader>lc",
      vim.lsp.codelens.refresh,
      { buffer = bufnr, noremap = true, silent = true, desc = "Refresh code lens" }
    )
  end

  vim.lsp.config("roslyn", {
    capabilities = capabilities,
    on_attach = roslyn_on_attach,
    settings = {
      ["csharp|background_analysis"] = {
        -- openFiles keeps Roslyn from indexing the whole solution on attach
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
end

return M
