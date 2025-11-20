return {
  "williamboman/mason-lspconfig.nvim",
  event = { "LspAttach", "BufReadPost" },
  cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "hrsh7th/cmp-nvim-lsp", optional = true },
  },
  config = function()
    local mason_status, mason = pcall(require, "mason")
    if not mason_status then
      vim.notify("Failed to load mason: " .. tostring(mason), vim.log.levels.ERROR)
      return
    end

    mason.setup {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        check_outdated_packages_on_open = false,
      },
      max_concurrent_installers = 4,
    }

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument = capabilities.textDocument or {}
    capabilities.textDocument.positionEncoding = "utf-16"
    local cmp_lsp_status, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_lsp_status then
      capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
    end

    local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_status then
      vim.notify("Failed to load mason-lspconfig: " .. tostring(mason_lspconfig), vim.log.levels.ERROR)
      return
    end

    mason_lspconfig.setup {
      ensure_installed = {
        -- Web Development (React/React Native focused)
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "emmet_ls",
        "eslint",
        "jsonls",

        -- Python
        "pyright", -- FIXED: Removed duplicate
        "ruff",

        -- Other Languages
        "lua_ls",
        "bashls",
        "prismals",
        "intelephense",
      },
      automatic_installation = true,
      handlers = {
        -- Default handler for servers NOT configured in lspconfig.lua
        function(server_name)
          -- Skip servers that are manually configured in lspconfig.lua
          local skip_servers = {
            "ts_ls", -- Handled by typescript-tools
            "typescript_tools", -- Custom setup
            "pyright", -- Custom setup in lspconfig
            "ruff", -- Custom setup in lspconfig
            "html", -- Custom setup in lspconfig
            "tailwindcss", -- Custom setup in lspconfig
            "emmet_ls", -- Custom setup in lspconfig
            "lua_ls", -- Custom setup below
            "prismals", -- Custom setup in lspconfig
            "intelephense", -- Custom setup in lspconfig
          }

          if vim.tbl_contains(skip_servers, server_name) then
            return -- Let lspconfig.lua handle it
          end

          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
          }
        end,

        -- Only keep lua_ls here as it's simple and doesn't need lspconfig.lua
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup {
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
            settings = {
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
            },
          }
        end,
      },
    }

    local mason_tool_installer_status, mason_tool_installer = pcall(require, "mason-tool-installer")
    if not mason_tool_installer_status then
      vim.notify("Failed to load mason-tool-installer: " .. tostring(mason_tool_installer), vim.log.levels.ERROR)
      return
    end

    mason_tool_installer.setup {
      ensure_installed = {
        -- Formatters
        -- "prettierd",
        "prettier",
        "stylua",
        "black",
        "isort",

        -- Django (if you use it)
        "djlint",

        -- Other
        "php-cs-fixer",
        "google-java-format",
      },
      auto_update = false,
      run_on_start = true,
    }
  end,
}
