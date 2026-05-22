return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require "dap"
      require("lang.dotnet.dap").setup_adapter(dap)

      local function find_dotnet_dll()
        local dlls = vim.fn.globpath(vim.fn.getcwd(), "**/bin/Debug/**/*.dll", false, true)
        local default = ""

        for _, dll in ipairs(dlls) do
          if not dll:match "testhost%.dll$" and not dll:match "ref[/\\]" then
            default = dll
            break
          end
        end

        return vim.fn.input("Path to dll: ", default, "file")
      end

      dap.defaults.fallback.switchbuf = "useopen"
      dap.configurations.cs = dap.configurations.cs
        or {
          {
            type = "netcoredbg",
            name = "Launch .NET assembly",
            request = "launch",
            program = find_dotnet_dll,
            cwd = "${workspaceFolder}",
            stopAtEntry = false,
            console = "integratedTerminal",
          },
        }
    end,
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").continue()
        end,
        desc = "DAP continue",
      },
      {
        "<leader>dT",
        function()
          require("dap").terminate()
        end,
        desc = "DAP terminate",
      },
      {
        "<leader>dso",
        function()
          require("dap").step_over()
        end,
        desc = "DAP step over",
      },
      {
        "<leader>dsi",
        function()
          require("dap").step_into()
        end,
        desc = "DAP step into",
      },
      {
        "<leader>dsu",
        function()
          require("dap").step_out()
        end,
        desc = "DAP step out",
      },
      {
        "<leader>de",
        function()
          require("dap").eval()
        end,
        desc = "DAP evaluate expression",
        mode = { "n", "v" },
      },
    },
  },
}
