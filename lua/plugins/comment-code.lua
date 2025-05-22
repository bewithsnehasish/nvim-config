return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "VeryLazy" },
    config = function()
      local status, context_commentstring = pcall(require, "ts_context_commentstring")
      if not status then
        vim.notify(
          "Failed to load nvim-ts-context-commentstring: " .. tostring(context_commentstring),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Comment Error" }
        )
        return
      end

      context_commentstring.setup {
        enable_autocmd = false, -- Disable CursorHold updates for performance
        config = {
          javascript = "// %s",
          typescript = "// %s",
          javascriptreact = "{/* %s */}",
          typescriptreact = "{/* %s */}",
          svelte = "<!-- %s -->", -- Default for Svelte HTML
          html = "<!-- %s -->",
          css = "/* %s */",
          lua = "-- %s",
          python = "# %s",
          java = "// %s",
          php = "// %s",
          -- Custom context for Svelte scripts
          svelte_script = "{/* %s */}",
        },
        -- Custom function to handle commentstring updates with error handling
        update_commentstring = function()
          local ok, commentstring = pcall(require("ts_context_commentstring.internal").calculate_commentstring)
          if ok and type(commentstring) == "string" then
            vim.bo.commentstring = commentstring
          else
            vim.notify(
              "Failed to update commentstring: "
                .. (type(commentstring) == "string" and commentstring or "Invalid format"),
              vim.log.levels.WARN,
              { timeout = 2000, title = "Comment Warning" }
            )
          end
        end,
      }

      -- Manual update on BufEnter and CursorMoved for relevant filetypes
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
        group = vim.api.nvim_create_augroup("ContextCommentstring", { clear = true }),
        pattern = {
          "*.js",
          "*.ts",
          "*.jsx",
          "*.tsx",
          "*.svelte",
          "*.html",
          "*.css",
          "*.lua",
          "*.py",
          "*.java",
          "*.php",
        },
        callback = function()
          local ok, _ = pcall(context_commentstring.update_commentstring)
          if not ok then
            vim.notify(
              "Commentstring update failed",
              vim.log.levels.WARN,
              { timeout = 2000, title = "Comment Warning" }
            )
          end
        end,
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      local status, comment = pcall(require, "Comment")
      if not status then
        vim.notify(
          "Failed to load Comment.nvim: " .. tostring(comment),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Comment Error" }
        )
        return
      end

      comment.setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        mappings = {
          basic = true, -- Enable gcc, gc, gbc
          extra = true, -- Enable g>, g<, etc.
        },
        toggler = {
          line = "gcc", -- Line comment
          block = "gbc", -- Block comment
        },
        opleader = {
          line = "gc", -- Visual mode line comment
          block = "gb", -- Visual mode block comment
        },
        post_hook = function()
          vim.notify(
            "Commented/uncommented code",
            vim.log.levels.INFO,
            { timeout = 500, title = "Comment", icon = "💬" }
          )
        end,
      }
    end,
  },
}
