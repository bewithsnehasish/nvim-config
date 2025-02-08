return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "folke/neodev.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "stevearc/conform.nvim",
  },
  config = function()
    local lspconfig = require "lspconfig"
    local icons = require "plugins.user.icons"
    local on_attach = require "plugins.user.lsp.on_attach"
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    require("neodev").setup {}

    local diagnostic_config = {
      signs = {
        active = true,
        values = {
          { name = "DiagnosticSignError", text = icons.diagnostics.Error },
          { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
          { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
          { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
        },
      },
      virtual_text = true,
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    }
    vim.diagnostic.config(diagnostic_config)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

    local servers = {
      "ts_ls",
      "html",
      "eslint",
      "cssls",
      "jsonls",
      "lua_ls",
      "pyright",
      "bashls",
      "solidity_ls",
      "dockerls",
      "clangd",
      "tailwindcss",
      "prismals",
      "emmet_ls",
      "intelephense",
      "jdtls",
    }

    capabilities.textDocument.completion.completionItem = {
      documentationFormat = { "markdown", "plaintext" },
      snippetSupport = true,
      preselectSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      deprecatedSupport = true,
      commitCharactersSupport = true,
      resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      },
      tagSupport = {
        valueSet = { 1 },
      },
    }

    for _, server in ipairs(servers) do
      local server_config = {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          on_attach(client, bufnr)
        end,
        capabilities = capabilities,
      }

      if server == "ts_ls" then
        server_config.settings = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          typescript = {
            inlayHints = { includeInlayParameterNameHints = "all" },
            suggest = {
              includeCompletionsForModuleExports = true,
              autoImports = true,
              completeFunctionCalls = true,
              includeCompletionsWithSnippetText = true,
              classMemberSnippets = { enabled = true },
              objectLiteralMethodSnippets = { enabled = true },
              JSXAttributes = { enabled = true },
            },
            format = {
              insertSpaceAfterOpeningAndBeforeClosingJSXExpressionBraces = true,
            },
            preferences = {
              jsxAttributeCompletionStyle = "auto",
              allowRenameOfImportPath = true,
              includePackageJsonAutoImports = "auto",
              quoteStyle = "single",
            },
            updateImportsOnFileMove = {
              enabled = "always",
            },
          },
          javascript = {
            inlayHints = { includeInlayParameterNameHints = "all" },
            suggest = {
              includeCompletionsForModuleExports = true,
              autoImports = true,
              completeFunctionCalls = true,
              includeCompletionsWithSnippetText = true,
            },
            preferences = {
              jsxAttributeCompletionStyle = "auto",
              allowRenameOfImportPath = true,
              includePackageJsonAutoImports = "auto",
              quoteStyle = "single",
            },
          },
          completions = {
            completeFunctionCalls = true,
            autoImport = true,
            enabled = true,
          },
        }
      elseif server == "lua_ls" then
        server_config.settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        }
      elseif server == "pyright" then
        server_config.settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        }
      elseif server == "eslint" then
        server_config.settings = {
          workingDirectory = { mode = "auto" },
          validate = "on",
          packageManager = "npm",
          useESLintClass = false,
          experimental = { useFlatConfig = false },
          codeActionOnSave = { enable = false, mode = "all" },
          format = true,
          quiet = false,
          onIgnoredFiles = "off",
          rulesCustomizations = {},
          run = "onType",
          problems = { shortenToSingleLine = false },
        }
      elseif server == "prismals" then
        server_config.settings = {
          prisma = {
            validate = true, -- Enable validation (default: true)
            hover = true, -- Enable hover documentation (default: true)
            completions = {
              enabled = true, -- Enable autocompletion (default: true)
            },
          },
        }
      elseif server == "tailwindcss" then
        server_config.settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "classList", "ngClass" },
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning",
            },
            validate = true,
          },
        }
        server_config.filetypes = {
          "html",
          "javascriptreact",
          "javascript",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
          "astro",
          "php",
        }
      elseif server == "emmet_ls" then
        server_config.filetypes = {
          "html",
          "php",
          "javascriptreact",
          "typescriptreact",
          "css",
          "sass",
          "scss",
          "less",
          "blade",
        }
        server_config.init_options = {
          html = {
            options = {
              ["bem.enabled"] = true,
            },
          },
        }
      end

      lspconfig[server].setup(server_config)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
        "php",
      },
      callback = function()
        vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
      end,
    })
  end,
}
