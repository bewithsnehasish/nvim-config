return {
  -- Compiler plugin
  {
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim" },
    opts = {},
    config = function()
      require("compiler").setup()

      -- C++ compiler configuration
      require("compiler").set_compiler {
        filetype = "cpp",
        compiler = {
          cmd = "g++",
          args = {
            "-std=c++17",
            "-Wall",
            "-Wextra",
            "-O2",
            "-o",
            vim.fn.expand "%:p:r",
            vim.fn.expand "%:p",
          },
        },
        runner = {
          cmd = vim.fn.expand "%:p:r",
          args = {},
        },
      }

      -- Java compiler configuration
      require("compiler").set_compiler {
        filetype = "java",
        compiler = {
          cmd = "javac",
          args = {
            vim.fn.expand "%:p",
          },
        },
        runner = {
          cmd = "java",
          args = {
            "-cp",
            vim.fn.expand "%:p:h",
            vim.fn.expand "%:t:r",
          },
        },
      }
    end,
  },

  -- Overseer plugin (required by compiler.nvim)
  {
    "stevearc/overseer.nvim",
    commit = "3047ede61cc1308069ad1184c0d447ebee92d749", -- Use the latest stable commit
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
        bindings = {
          ["q"] = function()
            vim.cmd "OverseerClose"
          end,
        },
      },
    },
  },
  config = function()
    vim.keymap.set("n", "<F5>", "<cmd>CompilerOpen<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<F6>", "<cmd>CompilerRedo<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<F7>", "<cmd>CompilerToggleResults<CR>", { noremap = true, silent = true })
  end,
}
