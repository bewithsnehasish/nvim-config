return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "folke/lazydev.nvim",
      "williamboman/mason.nvim",
      "stevearc/conform.nvim",
      "RRethy/vim-illuminate",
      "pmizio/typescript-tools.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Removed cmp_nvim_lsp imports as blink.cmp handles it directly

      local typescript_tools_status, typescript_tools = pcall(require, "typescript-tools")
      if not typescript_tools_status then
        vim.notify("Failed to load typescript-tools", vim.log.levels.WARN, {
          timeout = 2000,
          title = "LSP Warning",
          icon = "⚠️",
        })
      end

      local on_attach = require "lsp.on_attach"

      -- 2. Lazydev Setup (must be before lspconfig for Lua LSP support)
      require("lazydev").setup {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      }

      -- 3. Capabilities Configuration (Using blink.cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local blink_status, blink = pcall(require, "blink.cmp")
      if blink_status then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

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

      -- 5. Enhanced On-Attach is now consolidated in lua/lsp/on_attach.lua

      -- 6. TypeScript Tools Setup
      -- Mason integration is built-in since typescript-tools commit (2025) — no need to
      -- resolve tsserver path manually; the plugin discovers it from Mason automatically.
      if typescript_tools_status then
        typescript_tools.setup {
          filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
          },
          capabilities = capabilities,
          on_attach = on_attach,
          flags = { debounce_text_changes = 150 },
          settings = {
            separate_diagnostic_server = true,
            publish_diagnostic_on = "insert_leave",
            expose_as_code_action = "all",
            tsserver_file_preferences = {
              -- "literals" only: hints for non-obvious params, not every single arg
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

      -- 7. Server Configurations — one file per server under lua/lsp/servers/
      local server_configs = {}
      local servers_dir = vim.fs.joinpath(vim.fn.stdpath "config", "lua", "lsp", "servers")
      for _, fname in ipairs(vim.fn.readdir(servers_dir, [[v:val =~ '\.lua$']])) do
        local name = fname:gsub("%.lua$", "")
        local ok, spec = pcall(require, "lsp.servers." .. name)
        if ok then
          server_configs[name] = spec
        else
          vim.notify(
            "Failed to load LSP server config: " .. name .. "\n" .. tostring(spec),
            vim.log.levels.ERROR
          )
        end
      end


      -- Apply each server config (Neovim 0.12+ native API)
      for server_name, config in pairs(server_configs) do
        local default_config = {
          capabilities = capabilities,
          on_attach = config.on_attach or on_attach,
          flags = { debounce_text_changes = 150 },
        }
        local final_config = vim.tbl_deep_extend("force", default_config, config)
        vim.lsp.config(server_name, final_config)
        vim.lsp.enable(server_name)
      end


      -- 8. Omnifunc for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua",
          "html",
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
