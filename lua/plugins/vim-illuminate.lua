-- lua/plugins/illuminate.lua
return {
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      -- Define custom highlight groups
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3E4452" }) -- Change this to your preferred color
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3E4452" }) -- Change this to your preferred color
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3E4452" }) -- Change this to your preferred color

      require("illuminate").configure {
        delay = 100,
        modes_allowlist = { "n", "v", "i" },
        providers = {
          "lsp",
          "treesitter",
          "regex",
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
        filetypes_allowlist = {},
        modes_denylist = {},
      }
    end,
  },
}
