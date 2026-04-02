return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "folke/lazydev.nvim",
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
      local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if not cmp_nvim_lsp_status then
        vim.notify("Failed to load cmp-nvim-lsp, using base capabilities", vim.log.levels.WARN, {
          timeout = 2000,
          title = "LSP Warning",
          icon = "⚠️",
        })
      end

      local typescript_tools_status, typescript_tools = pcall(require, "typescript-tools")
      if not typescript_tools_status then
        vim.notify("Failed to load typescript-tools", vim.log.levels.WARN, {
          timeout = 2000,
          title = "LSP Warning",
          icon = "⚠️",
        })
      end

      local on_attach = require "user.lsp.on_attach"

      local function find_local_python(root)
        local candidates = {
          root .. "/.venv/bin/python",
          root .. "/.venv/Scripts/python.exe",
          root .. "/.venv/Scripts/python",
        }

        for _, candidate in ipairs(candidates) do
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end
      end

      -- 2. Lazydev Setup (must be before lspconfig for Lua LSP support)
      require("lazydev").setup {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      }

      -- 3. Capabilities Configuration
      local capabilities = cmp_nvim_lsp_status
          and cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
        or vim.lsp.protocol.make_client_capabilities()

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

      -- 4. UI / Diagnostic Configuration
      local diagnostic_config = {
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
        virtual_text = {
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = "",
              [vim.diagnostic.severity.WARN] = "",
              [vim.diagnostic.severity.HINT] = "",
              [vim.diagnostic.severity.INFO] = "",
            }
            return icons[diagnostic.severity] or "●"
          end,
          spacing = 4,
          source = "if_many",
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "if_many",
          header = "Diagnostics:",
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
              [vim.diagnostic.severity.INFO] = " ",
            }
            local severity = vim.diagnostic.severity[diagnostic.severity]
            return icons[diagnostic.severity] .. severity:sub(1, 1) .. ": "
          end,
          format = function(diagnostic)
            local source = diagnostic.source or "unknown"
            return string.format("%s (%s)", diagnostic.message, source)
          end,
          max_width = 100,
        },
      }
      vim.diagnostic.config(diagnostic_config)

      -- Highlight groups
      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ff5555", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#ffaa00", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#55aaff", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#55ff55", bold = true })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5555" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#ffaa00" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#55aaff" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#55ff55" })

      -- FIX 9: Replaced vim.lsp.with (deprecated in 0.11+) with plain handler functions
      if vim.lsp.config then
        vim.lsp.config("*", {
          handlers = {
            ["textDocument/hover"] = function(err, result, ctx, config)
              return vim.lsp.handlers.hover(
                err,
                result,
                ctx,
                vim.tbl_extend("force", config or {}, { border = "rounded" })
              )
            end,
            ["textDocument/signatureHelp"] = function(err, result, ctx, config)
              return vim.lsp.handlers.signature_help(
                err,
                result,
                ctx,
                vim.tbl_extend("force", config or {}, { border = "rounded" })
              )
            end,
          },
        })
      else
        -- Fallback for Neovim < 0.11 (vim.lsp.with is NOT deprecated there)
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      end

      -- 5. Enhanced On-Attach
      local custom_on_attach = function(client, bufnr)
        -- Disable formatting if conform.nvim has a formatter for this buffer
        local conform_status, conform = pcall(require, "conform")
        if conform_status then
          local formatters = conform.list_formatters(bufnr)
          if formatters and #formatters > 0 then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end

        on_attach(client, bufnr)

        local opts = { buffer = bufnr, noremap = true, silent = true }

        -- 🔍 INTERACTIVE DIAGNOSTIC FLOAT — moved to <leader>ld (LSP namespace)
        -- Reason: <leader>d was buffer-local and had higher priority than global
        -- DAP keymaps (<leader>db, <leader>dr, etc.), causing them to fail.
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
            -- FIX 3: Focus float first, then set keymaps directly.
            --        WinEnter already fired by the time the autocmd was registered,
            --        so keymaps inside WinEnter callback were never being set.
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

            -- FIX 4: WinClosed with once=true handles cleanup and focus restore.
            --        Replaced the named augroup (DiagnosticFloat_N) that was leaking
            --        a new augroup on every <leader>d press without ever being deleted.
            -- FIX 5: Removed the dead WinLeave autocmd that had a string/int type
            --        mismatch on args.match and an empty body.
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
        end, opts)

        -- Navigation
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump { count = 1, float = true }
        end, opts)
        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump { count = -1, float = true }
        end, opts)

        -- Raw diagnostic inspector (kept out of <leader>d DAP namespace)
        vim.keymap.set("n", "<leader>lD", function()
          local diags = vim.diagnostic.get(bufnr)
          print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
        end, vim.tbl_extend("force", opts, { desc = "Inspect raw diagnostics" }))

        -- Auto-hover on CursorHold (non-interactive, quick glance)
        local filetype = vim.bo[bufnr].filetype
        if filetype ~= "htmldjango" then
          local group = vim.api.nvim_create_augroup("LspDiagnosticsHover_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            group = group,
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
        end
      end

      -- 6. TypeScript Tools Setup
      if typescript_tools_status then
        -- Resolve tsserver from Mason's typescript-language-server bundle.
        -- typescript-tools searches local node_modules + global npm, but NOT Mason.
        -- This makes it work even when TypeScript is not installed globally.
        local mason_tsserver = vim.fn.stdpath "data"
          .. "/mason/packages/typescript-language-server/node_modules/typescript/bin/tsserver"
        local tsserver_path = vim.fn.filereadable(mason_tsserver) == 1 and mason_tsserver or nil

        typescript_tools.setup {
          filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
          },
          capabilities = capabilities,
          on_attach = custom_on_attach,
          flags = { debounce_text_changes = 150 },
          settings = {
            tsserver_path = tsserver_path,
            separate_diagnostic_server = true,
            publish_diagnostic_on = "insert_leave",
            expose_as_code_action = "all",
            tsserver_file_preferences = {
              -- "literals" only: shows hints for non-obvious params, not every single arg
              includeInlayParameterNameHints = "literals",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = false,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = false,
              includeInlayFunctionLikeReturnTypeHints = false,
              includeInlayEnumMemberValueHints = true,
              includeCompletionsForModuleExports = true,
              quotePreference = "auto",
            },
            tsserver_format_options = {
              allowIncompleteCompletions = false,
              allowRenameOfImportPath = false,
            },
          },
        }
      end

      -- 7. Server Configurations
      local server_configs = {
        -- FIX 6: Added missing lua_ls config (was absent despite lazydev being set up)
        lua_ls = {
          filetypes = { "lua" },
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "require", "P", "R" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },

        pyright = {
          filetypes = { "python" },
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
              },
            },
          },
          before_init = function(_, config)
            local path = vim.fn.getcwd()
            local venv = find_local_python(path)
            if venv then
              config.settings.python.pythonPath = venv
            end
          end,
        },

        ruff = {
          filetypes = { "python" },
          settings = {
            ruff = { enable = true },
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            custom_on_attach(client, bufnr)
          end,
        },

        html = { filetypes = { "html", "htmldjango", "blade", "razor", "cshtml" } },
        cssls = {},
        jsonls = {
          -- on_new_config: defers schemastore require until the server actually starts,
          -- so lazy-loading of schemastore.nvim is preserved.
          on_new_config = function(new_config)
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
              new_config.settings = new_config.settings or {}
              new_config.settings.json = new_config.settings.json or {}
              new_config.settings.json.schemas = schemastore.json.schemas()
              new_config.settings.json.validate = { enable = true }
            end
          end,
        },
        bashls = {},

        tailwindcss = {
          filetypes = {
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
            "blade",
            "razor",
            "cshtml",
          },
          settings = {
            tailwindCSS = {
              classAttributes = { "class", "className", "classList", "ngClass" },
              experimental = {
                classRegex = {
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
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
          },
        },

        prismals = {
          settings = {
            prisma = {
              validate = true,
              hover = true,
              completions = { enabled = true },
            },
          },
        },

        emmet_ls = {
          filetypes = {
            "html",
            "htmldjango",
            "javascriptreact",
            "typescriptreact",
            "css",
            "scss",
            "sass",
            "svelte",
            "vue",
            "php",
            "blade",
          },
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = true,
                ["jsx.enabled"] = true,
              },
            },
          },
        },

        -- FIX 7: Scoped by root_dir so eslint and biome don't both activate
        --        on the same project simultaneously
        eslint = {
          root_dir = require("lspconfig.util").root_pattern(
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.json",
            ".eslintrc.cjs",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts"
          ),
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
          },
          settings = {
            codeAction = {
              disableRuleComment = { enable = true, location = "separateLine" },
              showDocumentation = { enable = true },
            },
            codeActionOnSave = { enable = false, mode = "all" },
            format = false,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            quiet = false,
            rulesCustomizations = {},
            run = "onSave",
            useESLintClass = false,
            validate = "on",
            workingDirectory = { mode = "auto" },
          },
        },

        intelephense = {
          filetypes = { "php", "blade" },
          settings = {
            intelephense = {
              environment = {
                includePaths = {
                  "vendor/laravel/framework/src",
                },
              },
              files = {
                maxSize = 5000000,
              },
            },
          },
        },

        graphql = {
          cmd = { "graphql-lsp", "server", "-m", "stream" },
          filetypes = { "graphql", "typescriptreact", "javascriptreact" },
          root_dir = require("lspconfig.util").root_pattern(".graphqlrc*", ".graphql.config.*", "graphql.config.*"),
        },

        biome = {
          root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "json",
            "jsonc",
          },
        },
      }

      -- Apply each server config
      for server_name, config in pairs(server_configs) do
        local default_config = {
          capabilities = capabilities,
          on_attach = config.on_attach or custom_on_attach,
          flags = { debounce_text_changes = 150 },
        }

        local final_config = vim.tbl_deep_extend("force", default_config, config)

        if vim.lsp.config then
          -- Neovim 0.11+ native API
          vim.lsp.config(server_name, final_config)
          vim.lsp.enable(server_name)
        else
          -- Fallback for Neovim < 0.11
          require("lspconfig")[server_name].setup(final_config)
        end
      end

      -- 8. Omnifunc for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "python",
          "lua",
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
          "blade",
          "cs",
          "razor",
          "cshtml",
          "graphql",
        },
        group = vim.api.nvim_create_augroup("LspOmnifunc", { clear = true }),
        callback = function()
          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
        end,
      })
    end,
  },
}
