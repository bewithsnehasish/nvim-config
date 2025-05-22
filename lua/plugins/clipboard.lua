return {
  {
    "ojroques/nvim-osc52",
    event = { "VeryLazy" },
    config = function()
      local status, osc52 = pcall(require, "osc52")
      if not status then
        vim.notify("Failed to load nvim-osc52: " .. tostring(osc52), vim.log.levels.ERROR)
        return
      end

      osc52.setup {
        max_length = 100000, -- Allow large selections (100KB)
        silent = false, -- Show copy notifications
        trim = true, -- Trim whitespace before copying
        tmux_passthrough = true, -- Support tmux with allow-passthrough
      }

      -- Keymappings
      vim.keymap.set(
        "n",
        "<leader>c",
        osc52.copy_operator,
        { expr = true, desc = "Copy to system clipboard", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>cc",
        "<leader>c_",
        { remap = true, desc = "Copy line to system clipboard", noremap = true }
      )
      vim.keymap.set(
        "v",
        "<leader>c",
        osc52.copy_visual,
        { desc = "Copy selection to system clipboard", noremap = true }
      )

      -- Clipboard provider
      local function copy(lines, _)
        local success, err = pcall(osc52.copy, table.concat(lines, "\n"))
        if success then
          vim.notify(
            "Copied to system clipboard",
            vim.log.levels.INFO,
            { timeout = 500, title = "Clipboard", icon = "📋" }
          )
        else
          vim.notify(
            "Failed to copy: " .. tostring(err),
            vim.log.levels.ERROR,
            { timeout = 2000, title = "Clipboard Error" }
          )
        end
      end

      local function paste()
        return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" }
      end

      vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
      }

      -- Auto-copy yanked text to + register
      vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("Osc52Yank", { clear = true }),
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
            local success, err = pcall(osc52.copy_register, "+")
            if success then
              vim.notify(
                "Yanked to system clipboard",
                vim.log.levels.INFO,
                { timeout = 500, title = "Clipboard", icon = "📋" }
              )
            else
              vim.notify(
                "Yank failed: " .. tostring(err),
                vim.log.levels.ERROR,
                { timeout = 2000, title = "Clipboard Error" }
              )
            end
          end
        end,
      })

      -- Notify about tmux setup if in tmux
      if vim.env.TMUX then
        vim.notify(
          "Ensure tmux has 'set -g allow-passthrough on' in ~/.tmux.conf for OSC52",
          vim.log.levels.WARN,
          { timeout = 5000, title = "Tmux Setup" }
        )
      end
    end,
  },
}
