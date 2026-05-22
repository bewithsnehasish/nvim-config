return {
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
      "olimorris/neotest-phpunit",
      "V13Axel/neotest-pest",
      "marilari88/neotest-vitest",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require "dap"
      local neotest = require "neotest"

      require("lang.dotnet.dap").setup_adapter(dap)

      local function project_command(local_bin, global_bin)
        local cwd = vim.fn.getcwd()
        local candidates = {
          vim.fs.joinpath(cwd, local_bin),
          vim.fs.joinpath(cwd, local_bin .. ".bat"),
          vim.fs.joinpath(cwd, local_bin .. ".cmd"),
        }

        for _, candidate in ipairs(candidates) do
          if vim.fn.filereadable(candidate) == 1 then
            return candidate
          end
        end

        return global_bin
      end

      dap.defaults.fallback.switchbuf = "useopen"

      neotest.setup {
        adapters = {
          require("lang.dotnet.neotest").adapter(),
          require "neotest-phpunit" {
            phpunit_cmd = function()
              return project_command(vim.fs.joinpath("vendor", "bin", "phpunit"), "phpunit")
            end,
            root_ignore_files = { "tests/Pest.php" },
            env = {
              XDEBUG_CONFIG = "idekey=neotest",
            },
            dap = dap.configurations.php and dap.configurations.php[1] or nil,
          },
          require "neotest-vitest" {},
          require "neotest-pest" {
            pest_cmd = function()
              return project_command(vim.fs.joinpath("vendor", "bin", "pest"), "pest")
            end,
            sail_enabled = function()
              local cwd = vim.fn.getcwd()
              return vim.fn.filereadable(vim.fs.joinpath(cwd, "vendor", "bin", "sail")) == 1
            end,
            root_ignore_files = { "phpunit-only.tests" },
          },
        },
      }
    end,
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Run file tests",
      },
      {
        "<leader>ts",
        function()
          require("neotest").run.run { suite = true }
        end,
        desc = "Run test suite",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run { strategy = "dap" }
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true, auto_close = true }
        end,
        desc = "Open test output",
      },
      {
        "<leader>tt",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle test summary",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run last test",
      },
    },
  },
}
