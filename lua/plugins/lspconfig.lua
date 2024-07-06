-- lua/plugins/lsp_and_mason.lua
return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup {
        ui = {
          border = "rounded",
        },
      }
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
      local servers = {
        "lua_ls",
        "cssls",
        "html",
        "tsserver",
        "pyright",
        "bashls",
        "jsonls",
      }

      require("mason-lspconfig").setup {
        ensure_installed = servers,
      }
    end,
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason-lspconfig.nvim", -- Added mason-lspconfig as a dependency
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- Setup LSP servers
      lspconfig.tsserver.setup({
        capabilities = capabilities,
      })
      lspconfig.html.setup({
        capabilities = capabilities,
        filetypes = { "html", "ejs" }, -- Added support for EJS
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              path = vim.split(package.path, ";"),
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
      lspconfig.solargraph.setup({
        capabilities = capabilities,
        cmd = { "solargraph", "stdio" }, -- Use system-installed solargraph
        filetypes = { "ruby" },
        root_dir = require("lspconfig/util").root_pattern("Gemfile", ".git"),
        settings = {
          solargraph = {
            diagnostics = true,
          },
        },
      })

      -- Keybindings for LSP functions
      -- Consider moving these to a separate keymaps configuration file if they are duplicated
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
