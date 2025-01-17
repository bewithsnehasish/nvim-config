return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- Load on buffer read or new file creation
  config = function()
    local conform = require "conform"

    conform.setup {
      -- Define formatters for specific filetypes
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "superhtml" },
        html = { "djlint" },
        json = { "prettier" },
        cpp = { "clang-format" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        java = { "astyle" },
        php = { "php_cs_fixer", "djlint" }, -- Use php-cs-fixer for PHP files
      },

      -- Custom formatter configurations
      formatters = {
        php_cs_fixer = {
          command = "php-cs-fixer", -- Ensure this matches the binary name
          args = { "fix", "$FILENAME" }, -- Arguments for php-cs-fixer
          stdin = false, -- php-cs-fixer does not support stdin
        },
      },

      -- Format on save settings
      format_on_save = {
        lsp_fallback = true, -- Fallback to LSP formatting if no formatter is available
        async = false, -- Run formatting synchronously
        timeout_ms = 1000, -- Timeout for formatting
      },
    }

    -- Keymap to format the current file or visual selection
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format {
        lsp_fallback = true, -- Fallback to LSP formatting if no formatter is available
        async = false, -- Run formatting synchronously
        timeout_ms = 1000, -- Timeout for formatting
      }
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
