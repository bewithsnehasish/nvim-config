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
          vim.log.levels.WARN,
          { timeout = 2000, title = "LSP Warning", icon = "⚠️" }
        )
      end

      local on_attach = require "plugins.user.lsp.on_attach"

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
          text = {
            [vim.diagnostic.severity.ERROR] = "", -- ERROR
            [vim.diagnostic.severity.WARN] = "", -- WARN
            [vim.diagnostic.severity.HINT] = "", -- HINT
            [vim.diagnostic.severity.INFO] = "", -- INFO
          },
          -- Optional: add colors via linehl/numhl
        },
        virtual_text = {
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = "",
              [vim.diagnostic.severity.WARN] = "",
              [vim.diagnostic.severity.HINT] = "",
              [vim.diagnostic.severity.INFO] = "",
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

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- 4. Enhanced On-Attach
      local custom_on_attach = function(client, bufnr)
        -- Disable formatting if conform.nvim has a formatter
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

        -- 🔍 INTERACTIVE DIAGNOSTIC FLOAT (focusable + selectable + yankable)
        vim.keymap.set("n", "<leader>d", function()
          local winid = vim.fn.win_getid()
          local float_opts = {
            scope = "cursor",  -- or "line" if you prefer
            focusable = true,
            close_events = {}, -- disable auto-close
            border = "rounded",
            source = "if_many",
            -- Optional: custom format
            format = function(diagnostic)
              local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
              return string.format("%s%s", diagnostic.message, source)
            end,
          }

          -- Open float
          local float_bufnr, float_winid = vim.diagnostic.open_float(nil, float_opts)

          if float_winid then
            -- Switch focus to float window
            vim.fn.win_gotoid(float_winid)

            -- Create augroup for float-local keymaps
            local float_group = vim.api.nvim_create_augroup("DiagnosticFloat_" .. float_winid, { clear = true })

            -- Keymaps inside the float
            vim.api.nvim_create_autocmd("WinEnter", {
              group = float_group,
              buffer = float_bufnr,
              callback = function()
                -- Yank entire float content
                vim.keymap.set("n", "<C-y>", function()
                  vim.cmd("normal! ggVGy")
                  vim.notify("Diagnostic text yanked!", vim.log.levels.INFO, { title = "Yank" })
                end, { buffer = float_bufnr, nowait = true })

                -- Close float (like <Esc>)
                vim.keymap.set("n", "<Esc>", function()
                  vim.api.nvim_win_close(float_winid, true)
                  vim.fn.win_gotoid(winid) -- return to original window
                end, { buffer = float_bufnr, nowait = true })

                -- Optional: go back to source on <CR>
                vim.keymap.set("n", "<CR>", function()
                  vim.api.nvim_win_close(float_winid, true)
                  vim.fn.win_gotoid(winid)
                end, { buffer = float_bufnr, nowait = true })
              end,
            })

            -- Optional: close float when leaving it
            vim.api.nvim_create_autocmd("WinLeave", {
              group = float_group,
              callback = function(args)
                if args.match == float_winid then
                  -- Don't auto-close — let user control it
                  -- (remove this if you want auto-close on leave)
                end
              end,
            })
          else
            vim.notify("No diagnostics at cursor", vim.log.levels.WARN)
          end
        end, opts)

        -- Navigation keymaps (still useful!)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        -- Debug: inspect raw diagnostics
        vim.keymap.set("n", "<leader>dd", function()
          local diags = vim.diagnostic.get(bufnr)
          print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
        end, opts)

        -- Auto-hover (non-interactive, for quick glance)
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

      vim.o.updatetime = 300

      -- 5. TypeScript Tools Setup (for React/React Native)
      if typescript_tools_status then
        typescript_tools.setup {
          filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "typescript.tsx",
            "javascript.jsx",
          },
          capabilities = capabilities,
          on_attach = custom_on_attach,
          flags = { debounce_text_changes = 150 },
          settings = {
            separate_diagnostic_server = true,
            publish_diagnostic_on = "insert_leave",
            expose_as_code_action = "all",
            tsserver_file_preferences = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
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

      -- 6. Server Configurations using new vim.lsp.config API
      local server_configs = {
        pyright = {
          filetypes = { "python" },
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
              },
            },
          },
          before_init = function(_, config)
            local path = vim.fn.getcwd()
            local venv = path .. "/.venv/bin/python"
            if vim.fn.executable(venv) == 1 then
              config.settings.python.pythonPath = venv
            end
          end,
        },
        ruff = {
          filetypes = { "python" },
          settings = {
            ruff = {
              enable = true,
            }
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            custom_on_attach(client, bufnr)
          end,
        },
        html = {
          filetypes = { "html", "htmldjango" },
        },
        cssls = {},
        jsonls = {},
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
          },
          settings = {
            tailwindCSS = {
              classAttributes = { "class", "className", "classList", "ngClass" },
              experimental = {
                classRegex = {
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  { "cx\\(([^)]*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },
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
          },
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = true,
                ["jsx.enabled"] = true,
              }
            },
          },
        },
        eslint = {
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
              disableRuleComment = {
                enable = true,
                location = "separateLine",
              },
              showDocumentation = {
                enable = true,
              },
            },
            codeActionOnSave = {
              enable = false,
              mode = "all",
            },
            format = false,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            quiet = false,
            rulesCustomizations = {},
            run = "onType",
            useESLintClass = false,
            validate = "on",
            workingDirectory = {
              mode = "location",
            },
          },
        },
        intelephense = {
          filetypes = { "php" },
        },
      }

      -- Setup each server using the new API
      for server_name, config in pairs(server_configs) do
        local default_config = {
          capabilities = capabilities,
          on_attach = config.on_attach or custom_on_attach,
          flags = { debounce_text_changes = 150 },
        }

        -- Merge custom config with defaults
        local final_config = vim.tbl_deep_extend("force", default_config, config)

        -- Use new API if available (Neovim 0.11+), fallback to lspconfig
        if vim.lsp.config then
          vim.lsp.config(server_name, final_config)
        else
          -- Fallback for older Neovim versions
          require("lspconfig")[server_name].setup(final_config)
        end
      end

      -- 7. Neodev Setup (for Neovim Lua development)
      require("neodev").setup {
        library = {
          enabled = true,
          runtime = true,
          types = true,
          plugins = true,
        },
      }

      -- 8. Omnifunc for specific filetypes
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
