return {
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3E4452", underline = false })

      vim.keymap.set("n", "]r", function()
        require("illuminate").goto_next_reference()
      end, { desc = "Next reference (illuminate)" })
      vim.keymap.set("n", "[r", function()
        require("illuminate").goto_prev_reference()
      end, { desc = "Prev reference (illuminate)" })

      vim.keymap.set("n", "<leader>ui", function()
        require("illuminate").toggle()
        vim.notify(
          "Illuminate " .. (require("illuminate").is_paused() and "disabled" or "enabled"),
          vim.log.levels.INFO,
          { title = "Illuminate", timeout = 1500 }
        )
      end, { desc = "Toggle reference highlighting" })

      require("illuminate").configure {
        delay = 300,
        modes_allowlist = { "n", "v" },
        -- nvim-treesitter main branch doesn't expose `nvim-treesitter.locals`
        -- that illuminate's treesitter provider depends on. lsp+regex covers the same UX.
        providers = { "lsp", "regex" },
        predicate = function(buf)
          return not vim.b[buf].large_file
        end,
        filetypes_denylist = {
          "mason", "harpoon", "DressingInput", "NeogitCommitMessage", "qf",
          "dirvish", "oil", "minifiles", "fugitive", "alpha", "NvimTree",
          "lazy", "NeogitStatus", "Trouble", "netrw", "lir", "DiffviewFiles",
          "Outline", "Jaq", "spectre_panel", "toggleterm", "DressingSelect",
          "TelescopePrompt",
        },
        under_cursor = true,
      }
    end,
  },
}
