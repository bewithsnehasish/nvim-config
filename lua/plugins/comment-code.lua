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
          blade = "{{-- %s --}}", -- Custom Blade support
        },
      }
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
      }
    end,
  },
}
