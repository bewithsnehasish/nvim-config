return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gf", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Filter" },
    { "<leader>gc", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Filter Current File" },
  },
  config = function()
    -- Load Telescope extension
    require("telescope").load_extension "lazygit"

    -- Configuration options
    vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- customize lazygit popup window border characters
    vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
    vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

    -- Optional: Set up autocmd to track git repos for Telescope
    vim.cmd [[
      autocmd BufEnter * :lua require('lazygit.utils').project_root_dir()
    ]]

    -- Optional: Set up custom highlighting
    vim.cmd [[
      highlight LazyGitFloat guibg=#1e222a guifg=#abb2bf
      highlight LazyGitBorder guifg=#3e4451
    ]]
  end,
}
