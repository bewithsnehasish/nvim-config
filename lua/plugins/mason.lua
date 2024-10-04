-- lua/plugins/mason.lua
local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  event = "BufReadPre", -- Load mason and mason-lspconfig before buffer is read
}

function M.config()
  -- List of servers to install and set up
  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "jdtls",
    "eslint",
    "emmet_ls",
    "ts_ls",
    "pyright",
    "bashls",
    "jsonls",
    "yamlls",
    "tailwindcss",
    "clangd",
    "dockerls",
  }

  -- Mason setup
  require("mason").setup {
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  }

  -- Mason-lspconfig setup
  require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_installation = true, -- Automatically install LSP servers
  }

  -- Mason-tool-installer setup
  require("mason-tool-installer").setup {
    ensure_installed = {
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      "isort", -- python formatter
      "black", -- python formatter
      "pylint", -- python linter
    },
  }
end

return M
