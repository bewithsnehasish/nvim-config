return {
  {
    "mg979/vim-visual-multi",
    keys = {
      { "<C-n>", mode = { "n", "x" }, desc = "Visual Multi (Select Word)" },
      { "<C-Down>", mode = { "n" }, desc = "Visual Multi (Add Cursor Down)" },
      { "<C-Up>", mode = { "n" }, desc = "Visual Multi (Add Cursor Up)" },
    },
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor Up"] = "<C-Up>",
      }
    end,
  },
}
