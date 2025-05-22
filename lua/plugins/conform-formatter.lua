return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufReadPost" },
    cmd = { "ConformInfo" },
    config = function()
      local status, conform = pcall(require, "conform")
      if not status then
        vim.notify(
          "Failed to load conform.nvim",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Conform Error", icon = "❌" }
        )
        return
      end

      conform.setup {
        formatters_by_ft = {
          -- Django and Python
          python = { "isort", "black", "ruff_fix" },
          htmldjango = { "djlint" },
          -- Web Development
          javascript = { "prettier", "prettierd" }, -- Reversed to prefer prettier
          typescript = { "prettier", "prettierd" },
          javascriptreact = { "prettier", "prettierd" },
          typescriptreact = { "prettier", "prettierd" },
          svelte = { "prettier", "prettierd" },
          css = { "prettier", "prettierd" },
          html = { "prettier", "prettierd" },
          json = { "prettier", "prettierd" },
          yaml = { "prettier", "prettierd" },
          markdown = { "prettier", "prettierd" },
          graphql = { "prettier", "prettierd" },
          liquid = { "prettier", "prettierd" },
          -- Other Languages
          lua = { "stylua" },
          java = { "google-java-format" },
          php = { "php-cs-fixer" },
          prisma = { "prisma-format" },
        },
        formatters = {
          isort = {
            command = "isort",
            args = { "--quiet", "--filename", "$FILENAME", "-" },
            stdin = true,
          },
          black = {
            command = "black",
            args = { "--quiet", "--fast", "-" },
            stdin = true,
          },
          ruff_fix = {
            command = "ruff",
            args = { "format", "--quiet", "--stdin-filename", "$FILENAME", "-" },
            stdin = true,
          },
          djlint = {
            command = "djlint",
            args = { "--reformat", "--quiet", "-" },
            stdin = true,
            cwd = function()
              local templates_dir = vim.fn.finddir("templates", ".;")
              return templates_dir ~= "" and templates_dir:match "(.+)/templates" or vim.fn.getcwd()
            end,
          },
          prettier = {
            command = "prettier",
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
          },
          stylua = {
            command = "stylua",
            args = { "--search-parent-directories", "-" },
            stdin = true,
          },
          ["google-java-format"] = {
            command = "google-java-format",
            args = { "-" },
            stdin = true,
          },
          prisma_format = {
            command = "prisma", -- Ensure this matches the binary name
            args = { "format", "--stdin" }, -- Arguments for prisma format
            stdin = true, -- prisma format supports stdin
          },
          php_cs_fixer = {
            command = "php-cs-fixer",
            args = { "fix", "--quiet", "-" },
            stdin = true,
            condition = function()
              return vim.fn.filereadable ".php-cs-fixer.php" == 1 or vim.fn.filereadable ".php_cs" == 1
            end,
          },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 2000,
          async = false,
        },
        notify_on_error = true,
        notify_on_success = false, -- Handled by custom notification
      }

      -- Custom error handling for formatter failures
      local function notify_formatter_error(err, formatter)
        vim.notify(
          string.format("Formatter '%s' failed: %s", formatter, err),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Conform Error", icon = "❌" }
        )
      end

      -- Override format function to include error handling
      local original_format = conform.format
      conform.format = function(opts)
        local ok, err = pcall(original_format, opts)
        if not ok then
          local formatter = opts.formatters and table.concat(opts.formatters, ", ") or "unknown"
          notify_formatter_error(err, formatter)
        elseif not opts.async then
          vim.notify("Formatted buffer", vim.log.levels.INFO, { timeout = 500, title = "Conform", icon = "📝" })
        end
      end

      -- Keybinding for manual formatting
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format {
          lsp_fallback = true,
          async = true,
          timeout_ms = 2000,
        }
      end, { desc = "Format file or range (in visual mode)", noremap = true })
    end,
  },
}
