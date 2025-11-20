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
          -- Python
          python = { "isort", "black" },

          -- Django
          htmldjango = { "djlint" },

          -- Web Development (React/React Native focused)
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },

          -- Other Web
          svelte = { "prettierd", "prettier", stop_after_first = true },
          vue = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          scss = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          jsonc = { "prettierd", "prettier", stop_after_first = true },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          graphql = { "prettierd", "prettier", stop_after_first = true },

          -- Other Languages
          lua = { "stylua" },
          java = { "google-java-format" },
          php = { "php-cs-fixer" },
          prisma = { "prisma-format" },
        },

        formatters = {
          prettier = {
            prepend_args = {
              "--single-quote",
              "--jsx-single-quote",
              "--tab-width",
              "2",
              "--trailing-comma",
              "es5",
              "--print-width",
              "100",
              "--arrow-parens",
              "avoid",
            },
          },
          -- prettierd = {
          --   args = { "--stdin-filepath", "$FILENAME" },
          --   prepend_args = {
          --     "--single-quote",
          --     "--jsx-single-quote",
          --     "--tab-width",
          --     "2",
          --     "--trailing-comma",
          --     "es5",
          --     "--print-width",
          --     "100",
          --     "--arrow-parens",
          --     "avoid",
          --   },
          -- },
          isort = {
            prepend_args = { "--profile", "black" },
          },
          black = {
            prepend_args = { "--line-length", "100" },
          },
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
          ["php-cs-fixer"] = {
            command = "php-cs-fixer",
            args = { "fix", "$FILENAME" },
            stdin = false,
          },
        },

        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          return {
            timeout_ms = 2000,
            lsp_fallback = true,
          }
        end,

        format_after_save = {
          lsp_fallback = true,
        },

        notify_on_error = true,
      }

      -- Toggle format on save
      vim.api.nvim_create_user_command("FormatToggle", function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        if vim.g.disable_autoformat then
          vim.notify("Auto-format disabled", vim.log.levels.INFO)
        else
          vim.notify("Auto-format enabled", vim.log.levels.INFO)
        end
      end, {
        desc = "Toggle format on save",
      })

      -- Format command
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format { async = true, lsp_fallback = true, range = range }
      end, { range = true })

      -- Keybindings
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format {
          lsp_fallback = true,
          async = true,
          timeout_ms = 2000,
        }
      end, { desc = "Format file or range", noremap = true, silent = true })

      vim.keymap.set(
        "n",
        "<leader>mf",
        "<cmd>FormatToggle<cr>",
        { desc = "Toggle format on save", noremap = true, silent = true }
      )
    end,
  },
}
