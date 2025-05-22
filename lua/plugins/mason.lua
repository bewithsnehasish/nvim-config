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
        "ts_ls", -- Use ts_ls (handled by typescript-tools in lspconfig)
        "html",
        "eslint",
        "cssls",
        "pyright",
        "ruff",
        "jsonls",
        "lua_ls",
        "pyright",
        "bashls",
        "tailwindcss",
        "prismals",
        "emmet_ls",
        "intelephense",
        "jdtls",
      },
      automatic_installation = true,
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
          }
        end,
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
        ["jdtls"] = function()
          require("lspconfig").jdtls.setup {
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
            settings = {
              java = {
                configuration = { runtimes = {} },
                format = {
                  enabled = true,
                  settings = {
                    url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                  },
                },
              },
            },
          }
        end,
        ["emmet_ls"] = function()
          require("lspconfig").emmet_ls.setup {
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
            filetypes = { "html", "css", "svelte", "javascriptreact", "typescriptreact", "php" },
            init_options = { html = { options = { ["bem.enabled"] = true } } },
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
        "prettierd",
        "prettier",
        "djlint",
        "stylua",
        "black",
        "isort",
        "php-cs-fixer",
        "google-java-format",
      },
      auto_update = false,
    }
  end,
}
