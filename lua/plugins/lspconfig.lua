return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" }, -- Load LSP on buffer read or new file creation
  dependencies = {
    "folke/neodev.nvim", -- Neovim-specific Lua development tools
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
    "williamboman/mason.nvim", -- Package manager for LSP servers
    "hrsh7th/nvim-cmp", -- Autocompletion plugin
    "hrsh7th/cmp-buffer", -- Buffer source for nvim-cmp
    "stevearc/conform.nvim", -- Formatting plugin
  },
  config = function()
    local lspconfig = require "lspconfig"
    local icons = require "plugins.user.icons"
    local on_attach = require "plugins.user.lsp.on_attach"
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    -- Configure Neodev for Lua development
    require("neodev").setup {}

    -- Diagnostic configuration
    vim.diagnostic.config {
      signs = {
        active = true,
        values = {
          { name = "DiagnosticSignError", text = icons.diagnostics.Error },
          { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
          { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
          { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
        },
      },
      virtual_text = true, -- Show diagnostics inline
      update_in_insert = true, -- Update diagnostics while typing
      underline = true, -- Underline problematic code
      severity_sort = true, -- Sort diagnostics by severity
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    }

    -- Customize hover and signature help borders
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

    -- Server-specific configurations
    local servers = {
      ts_ls = {
        settings = {
          typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
          javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        },
      },
      eslint = {
        settings = {
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
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        },
      },
      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      },
      tailwindcss = {
        settings = {
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
        },
      },
      intelephense = {
        settings = {
          intelephense = {
            files = {
              maxSize = 5000000, -- Adjust file size limit if needed
            },
            storagePath = vim.fn.getenv "HOME" .. "/.intelephense", -- Custom storage path
            globalStoragePath = vim.fn.getenv "HOME" .. "/.intelephense", -- Global storage path
            licenceKey = nil, -- Set your license key here if needed
            clearCache = false, -- Set to true to clear cache on startup
          },
        },
        filetypes = { "php" }, -- Only PHP files
        root_dir = lspconfig.util.root_pattern("composer.json", ".git"), -- Detect root directory
      },
    }

    -- Set up each LSP server
    for server, config in pairs(servers) do
      lspconfig[server].setup {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false -- Disable formatting
          on_attach(client, bufnr) -- Attach custom keybindings and behaviors
        end,
        capabilities = capabilities, -- Add default capabilities
        settings = config.settings, -- Server-specific settings
        filetypes = config.filetypes, -- Server-specific filetypes
        root_dir = config.root_dir, -- Server-specific root directory detection
      }
    end

    -- Configure omnifunc for autocompletion in specific filetypes
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
      },
      callback = function()
        vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable LSP-based omnifunc
      end,
    })
  end,
}
