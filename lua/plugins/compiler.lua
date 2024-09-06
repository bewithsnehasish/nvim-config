return {
  -- The compiler.nvim plugin
  {
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
  },
  -- The overseer.nvim task runner
  {
    "stevearc/overseer.nvim",
    commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
  -- Configure the compiler.nvim plugin
  config = function()
    require("compiler").setup()

    -- Configure C++ compiler
    vim.g.compiler_commands = {
      cpp = {
        build = "g++ -std=c++17 -o %:r %",
        run = "./%:r",
      },
    }

    -- Configure Java compiler
    vim.g.compiler_commands = {
      java = {
        build = "javac %",
        run = "java %:r",
      },
    }

    -- Recommended keymaps
    -- Open compiler
    vim.api.nvim_set_keymap("n", "<F6>", "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })
    -- Redo last selected option
    vim.api.nvim_set_keymap(
      "n",
      "<S-F6>",
      "<cmd>CompilerStop<cr>" -- (Optional, to dispose all tasks before redo)
        .. "<cmd>CompilerRedo<cr>",
      { noremap = true, silent = true }
    )
    -- Toggle compiler results
    vim.api.nvim_set_keymap("n", "<S-F7>", "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })
  end,
}
