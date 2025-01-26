return {
  "williamboman/mason-lspconfig.nvim",
  event = "BufReadPre",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- Language servers that will be automatically installed
    local language_servers = {
      -- Web Development
      "html", -- HTML
      "cssls", -- CSS
      "ts_ls", -- TypeScript/JavaScript
      "eslint", -- ESLint
      "tailwindcss", -- Tailwind CSS
      "jsonls", -- JSON

      -- Programming Languages
      "lua_ls", -- Lua
      "pyright", -- Python
      "jdtls", -- Java
      "intelephense", -- PHP
      "emmet_ls", -- Emmet
      "prismals", -- Prisma
    }

    -- Code formatters and linters that will be automatically installed
    local tools = {
      -- Web Development
      "prettier", -- JavaScript, TypeScript, CSS, HTML formatter
      "djlint", -- HTML/Template formatter
      "stylua", -- Lua formatter
      "black", -- Python formatter
      "isort", -- Python import formatter
      "php-cs-fixer", -- PHP formatter
      "google-java-format", -- Java
    }

    -- Mason setup with nice icons
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

    -- Ensure language servers are installed
    require("mason-lspconfig").setup {
      ensure_installed = language_servers,
      automatic_installation = true,
    }

    -- Ensure formatters & linters are installed
    require("mason-tool-installer").setup {
      ensure_installed = tools,
    }
  end,
}
