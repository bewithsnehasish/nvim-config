return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
          -- Web Development (React/React Native focused)
          -- biome first: if biome.json exists, use it. prettierd fallback is fast (daemon).
          javascript = { "biome", "prettierd", stop_after_first = true },
          typescript = { "biome", "prettierd", stop_after_first = true },
          javascriptreact = { "biome", "prettierd", stop_after_first = true },
          typescriptreact = { "biome", "prettierd", stop_after_first = true },

          -- Other Web
          svelte = { "prettierd", stop_after_first = true },
          vue = { "prettierd", stop_after_first = true },
          css = { "prettierd", stop_after_first = true },
          scss = { "prettierd", stop_after_first = true },
          html = { "prettierd", stop_after_first = true },
          json = { "biome", "prettierd", stop_after_first = true },
          jsonc = { "biome", "prettierd", stop_after_first = true },
          yaml = { "prettierd", stop_after_first = true },
          markdown = { "prettierd", stop_after_first = true },
          graphql = { "prettierd", stop_after_first = true },

          -- C# / .NET
          cs     = { "csharpier" },
          razor  = { "csharpier" },
          cshtml = { "csharpier" },

          -- Other Languages
          lua = { "stylua" },
          php = { "php-cs-fixer" },
          -- prisma intentionally omitted: no `prisma-format` exists as a conform builtin.
          -- prismals LSP handles formatting via lsp_format = "fallback".
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
            lsp_format = "fallback",
          }
        end,

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
        require("conform").format { async = true, lsp_format = "fallback", range = range }
      end, { range = true })

      -- Keybindings
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format {
          lsp_format = "fallback",
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
