return {
  "williamboman/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "LspInstall", "LspUninstall" },
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason_status, mason = pcall(require, "mason")
    if not mason_status then
      vim.notify("Failed to load mason: " .. tostring(mason), vim.log.levels.ERROR)
      return
    end

    mason.setup {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
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

    -- Capabilities logic removed: this is handled centrally in lspconfig.lua

    local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_status then
      vim.notify("Failed to load mason-lspconfig: " .. tostring(mason_lspconfig), vim.log.levels.ERROR)
      return
    end

    mason_lspconfig.setup {
      ensure_installed = {
        -- Web Development (React/React Native focused)
        -- ts_ls is NOT activated as an LSP (handler skips it below).
        -- It IS installed so typescript-tools.nvim can use its bundled tsserver binary.
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "emmet_language_server",
        "eslint",
        "jsonls",
        "biome",

        -- Other Languages
        "lua_ls",
        "bashls",
        "prismals",
        "intelephense",

        "graphql",
      },
      automatic_installation = true,
      automatic_enable = {
        exclude = { "csharp_ls", "omnisharp", "roslyn", "ts_ls" },
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
        "prettierd",
        "prettier",
        "stylua",
        "csharpier",

        -- Other
        "php-cs-fixer",
        "netcoredbg",
        "php-debug-adapter",
        "roslyn",
        "shellcheck",
        "shfmt",

        -- JavaScript/TypeScript debugger
        "js-debug-adapter",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000, -- Delay execution by 3 seconds to avoid startup lag
      debounce_hours = 24, -- Check for updates at most once a day
    }
  end,
}
