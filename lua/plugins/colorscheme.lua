return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false, -- Load the theme on startup
    priority = 1000,
    config = function()
      vim.cmd("colorscheme cyberdream")
    end,
  },
}
