-- lua/plugins/illuminate.lua
return {
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      -- Define custom highlight groups with subtle styling to avoid clashing with diagnostics
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3E4452", underline = false })

      -- Jump between occurrences of the word under cursor
      vim.keymap.set("n", "]r", function() require("illuminate").goto_next_reference() end,
        { desc = "Next reference (illuminate)" })
      vim.keymap.set("n", "[r", function() require("illuminate").goto_prev_reference() end,
        { desc = "Prev reference (illuminate)" })

      require("illuminate").configure {
        delay = 300,
        modes_allowlist = { "n", "v" },
        providers = {
          "treesitter",
          "regex",
        },
        -- Skip illuminate on large files (set by the LargeFilePerf autocmd)
        predicate = function(buf)
          return not vim.b[buf].large_file
        end,
        filetypes_denylist = {
          "mason",
          "harpoon",
          "DressingInput",
          "NeogitCommitMessage",
          "qf",
          "dirvish",
          "oil",
          "minifiles",
          "fugitive",
          "alpha",
          "NvimTree",
          "lazy",
          "NeogitStatus",
          "Trouble",
          "netrw",
          "lir",
          "DiffviewFiles",
          "Outline",
          "Jaq",
          "spectre_panel",
          "toggleterm",
          "DressingSelect",
          "TelescopePrompt",
        },
        under_cursor = true, -- Highlight word under cursor
      }
    end,
  },
}
