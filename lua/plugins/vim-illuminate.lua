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

      require("illuminate").configure {
        delay = 100,
        modes_allowlist = { "n", "v" }, -- Remove "i" to reduce interference during typing
        providers = {
          "treesitter", -- Prioritize Treesitter for performance and accuracy
          "regex", -- Fallback to regex
          -- "lsp" removed to avoid overlap with ts_ls diagnostics
        },
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
