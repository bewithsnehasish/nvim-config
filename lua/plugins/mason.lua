return {
  "williamboman/mason-lspconfig.nvim",
  event = "BufReadPre",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "nvim-java/nvim-java", -- Add nvim-java as a dependency
  },
  config = function()
    -- Setup Mason with minimal UI config
    require("mason").setup {
      ui = {
        border = "rounded",
      },
    }

    -- Install and manage LSP servers
    require("mason-lspconfig").setup {
      ensure_installed = {
        "lua_ls", -- Lua
        "ts_ls", -- TypeScript/JavaScript (corrected from ts_ls)
        "eslint", -- JavaScript
        "html", -- HTML
        "cssls", -- CSS
        "pyright", -- Python
        "tailwindcss", -- Tailwind CSS
        "jsonls", -- JSON
        "jdtls", -- Java (added jdtls)
      },
      automatic_installation = true,
    }

    -- Install formatters and linters
    require("mason-tool-installer").setup {
      ensure_installed = {
        "prettier", -- Web formatter
        "stylua", -- Lua formatter
        "black", -- Python formatter
        "isort", -- Python formatter
        "djlint", -- HTML formatter (added)
      },
    }

    -- Configure nvim-java
    require("java").setup {
      jdtls = {
        -- Use the jdtls installed by mason
        cmd = { vim.fn.stdpath "data" .. "/mason/bin/jdtls" },
      },
      dap = {
        -- Configure Java Debug Adapter Protocol (DAP)
        hotcodereplace = "auto",
      },
    }
  end,
}

-- Old Config
-- return {
--   "williamboman/mason-lspconfig.nvim",
--   event = "BufReadPre",
--   dependencies = {
--     "williamboman/mason.nvim",
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--   },
--   config = function()
--     local servers = {
--       "lua_ls",
--       "cssls",
--       "html",
--       "jdtls",
--       "eslint",
--       "emmet_ls",
--       "ts_ls",
--       "pyright",
--       "bashls",
--       "jsonls",
--       "yamlls",
--       "tailwindcss",
--       "prismsls",
--       "clangd",
--       "dockerls",
--     }
--
--     require("mason").setup({
--       ui = {
--         border = "rounded",
--         icons = {
--           package_installed = "✓",
--           package_pending = "➜",
--           package_uninstalled = "✗",
--         },
--       },
--     })
--
--     require("mason-lspconfig").setup({
--       ensure_installed = servers,
--       automatic_installation = true,
--     })
--
--     require("mason-tool-installer").setup({
--       ensure_installed = {
--         "prettier",
--         "stylua",
--         "isort",
--         "black",
--         "pylint",
--       },
--     })
--   end,
-- }
