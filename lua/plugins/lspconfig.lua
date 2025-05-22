return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "stevearc/conform.nvim",
      "RRethy/vim-illuminate",
      "pmizio/typescript-tools.nvim",
    },
    config = function()
      -- 1. Imports
      local lspconfig_status, lspconfig = pcall(require, "lspconfig")
      if not lspconfig_status then
        vim.notify(
          "Failed to load nvim-lspconfig",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "LSP Error", icon = "❌" }
        )
        return
      end
      local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if not cmp_nvim_lsp_status then
        vim.notify(
          "Failed to load cmp-nvim-lsp",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "LSP Error", icon = "❌" }
        )
        return
      end
      local typescript_tools_status, typescript_tools = pcall(require, "typescript-tools")
      if not typescript_tools_status then
        vim.notify(
          "Failed to load typescript-tools",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "LSP Error", icon = "❌" }
        )
        return
      end
      local conform_status, conform = pcall(require, "conform")
      if not conform_status then
        vim.notify(
          "Failed to load conform.nvim",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "LSP Error", icon = "❌" }
        )
        return
      end
      local on_attach = require "plugins.user.lsp.on_attach"
      local icons = require "plugins.user.icons"

      -- 2. Capabilities Configuration
      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
      capabilities.textDocument.positionEncoding = "utf-16"
      capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
        tagSupport = { valueSet = { 1 } },
      }
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- 3. UI Configuration
      local diagnostic_config = {
        signs = {
          active = true,
          values = {
            { name = "DiagnosticSignError", text = " " },
            { name = "DiagnosticSignWarn", text = " " },
            { name = "DiagnosticSignHint", text = "󰌵 " },
            { name = "DiagnosticSignInfo", text = " " },
          },
        },
        virtual_text = {
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
              [vim.diagnostic.severity.INFO] = " ",
            }
            return icons[diagnostic.severity] or "● "
          end,
          source = "always",
          spacing = 4,
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = { "Diagnostics:", "DiagnosticHeader" },
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
              [vim.diagnostic.severity.INFO] = " ",
            }
            local severity = vim.diagnostic.severity[diagnostic.severity]
            return icons[diagnostic.severity] .. severity:sub(1, 1) .. ": ", "Diagnostic" .. severity
          end,
          format = function(diagnostic)
            return string.format("%s (%s)", diagnostic.message, diagnostic.source or "unknown")
          end,
          max_width = 80,
          padding = 1,
        },
      }
      vim.diagnostic.config(diagnostic_config)

      vim.api.nvim_set_hl(0, "DiagnosticHeader", { fg = "#569cd6", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ff5555", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#ffaa00", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#55aaff", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#55ff55", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5555" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#ffaa00" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#55aaff" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#55ff55" })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- 4. Enhanced On-Attach
      local custom_on_attach = function(client, bufnr)
        local filetype = vim.bo[bufnr].filetype
        if conform.get_formatter_info(filetype, bufnr) then
          client.server_capabilities.documentFormattingProvider = false
        end
        on_attach(client, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        if filetype ~= "htmldjango" then
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            group = vim.api.nvim_create_augroup("LspDiagnosticsHover_" .. bufnr, { clear = true }),
            callback = function()
              local float_opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always",
                prefix = diagnostic_config.float.prefix,
                format = diagnostic_config.float.format,
                max_width = diagnostic_config.float.max_width,
                padding = diagnostic_config.float.padding,
              }
              vim.diagnostic.open_float(nil, float_opts)
            end,
          })
        end
      end

      vim.o.updatetime = 500

      -- 5. Server Configuration
      local servers = {
        "pyright",
        "ruff",
        "html",
        "cssls",
        "jsonls",
        "lua_ls",
        "bashls",
        "tailwindcss",
        "prismals",
        "emmet_ls",
        "intelephense",
        "jdtls",
        "typescript_tools",
      }

      typescript_tools.setup {
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        capabilities = capabilities,
        on_attach = custom_on_attach,
        flags = { debounce_text_changes = 150 },
        settings = {
          separate_diagnostic_server = false,
          typescript = {
            inlayHints = { includeInlayParameterNameHints = "all" },
            suggest = {
              includeCompletionsForModuleExports = true,
              autoImports = true,
              completeFunctionCalls = true,
              includeCompletionsWithSnippetText = true,
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
          },
        },
      }

      for _, server in ipairs(servers) do
        local server_config = {
          capabilities = capabilities,
          on_attach = custom_on_attach,
          flags = { debounce_text_changes = 150 },
          on_init = function(client)
            if not client then
              vim.notify(
                "Failed to start LSP: " .. server,
                vim.log.levels.WARN,
                { timeout = 2000, title = "LSP Warning", icon = "⚠️" }
              )
            end
          end,
        }

        if server == "pyright" then
          server_config.filetypes = { "python" }
          server_config.settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
              },
            },
          }
          server_config.before_init = function(_, config)
            local path = vim.fn.getcwd()
            local venv = path .. "/.venv/bin/python"
            if vim.fn.executable(venv) == 1 then
              config.settings.python.pythonPath = venv
            end
          end
        elseif server == "ruff" then
          server_config.filetypes = { "python" }
          server_config.on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            custom_on_attach(client, bufnr)
          end
        elseif server == "html" then
          server_config.filetypes = { "html", "htmldjango" }
        elseif server == "lua_ls" then
          server_config.settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "require" },
                disable = { "missing-fields" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          }
        elseif server == "tailwindcss" then
          server_config.filetypes = {
            "html",
            "htmldjango",
            "javascriptreact",
            "javascript",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "astro",
            "php",
          }
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
        elseif server == "emmet_ls" then
          server_config.filetypes = {
            "html",
            "htmldjango",
            "javascriptreact",
            "typescriptreact",
            "css",
            "svelte",
            "php",
          }
          server_config.init_options = {
            html = { options = { ["bem.enabled"] = true } },
          }
        elseif server == "prismals" then
          server_config.settings = {
            prisma = {
              validate = true,
              hover = true,
              completions = { enabled = true },
            },
          }
        elseif server == "intelephense" then
          server_config.filetypes = { "php" }
        end

        if server ~= "jdtls" and server ~= "typescript_tools" then
          lspconfig[server].setup(server_config)
        end
      end

      -- 6. Neodev Setup
      require("neodev").setup {}

      -- 7. Omnifunc for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "python",
          "html",
          "htmldjango",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
          "astro",
          "php",
        },
        group = vim.api.nvim_create_augroup("LspOmnifunc", { clear = true }),
        callback = function()
          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
        end,
      })
    end,
  },
}
