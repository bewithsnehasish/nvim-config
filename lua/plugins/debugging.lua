return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      -- nvim-dap-ui: scopes/watches/repl/stacks panes that open on debug start
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- required by dap-ui
      -- Inline virtual-text values next to variables while stepping
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      require("lang.dotnet.dap").setup_adapter(dap)

      -- ── dap-ui layout ────────────────────────────────────────────────────────
      -- Left column: scopes + breakpoints + stacks + watches
      -- Bottom row : repl + console (toggle between)
      dapui.setup {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
            disconnect = "",
          },
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.20 },
              { id = "watches", size = 0.20 },
            },
            size = 40, -- columns
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10, -- rows
            position = "bottom",
          },
        },
        floating = { border = "rounded" },
      }

      require("nvim-dap-virtual-text").setup {
        commented = true,
        virt_text_pos = "eol",
      }

      -- ── Auto-open / auto-focus on debug session start ─────────────────────────
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
        -- Move cursor into the scopes pane (top of left column) so you can
        -- expand variables / watches immediately without grabbing the mouse.
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "dapui_scopes" then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
        end)
      end
      dap.listeners.before.launch.dapui_config = dap.listeners.before.attach.dapui_config
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

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
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dr", function() require("dap").continue() end, desc = "DAP continue" },
      { "<leader>dT", function() require("dap").terminate() end, desc = "DAP terminate" },
      { "<leader>dso", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<leader>dsi", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<leader>dsu", function() require("dap").step_out() end, desc = "DAP step out" },
      { "<leader>de", function() require("dap").eval() end, desc = "DAP evaluate expression", mode = { "n", "v" } },

      -- ── dap-ui controls ────────────────────────────────────────────────────
      -- <leader>du  → toggle the full debug UI (scopes + breakpoints + repl + …)
      -- <leader>df  → jump cursor INTO the scopes pane (works anytime the UI is open)
      -- <leader>dh  → hover popup with the value under cursor
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      {
        "<leader>df",
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft == "dapui_scopes" or ft == "dapui_watches" or ft == "dapui_stacks" then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
          vim.notify("DAP UI not open. Press <leader>du first.", vim.log.levels.WARN)
        end,
        desc = "Focus DAP UI",
      },
      { "<leader>dh", function() require("dapui").eval(nil, { enter = true }) end, desc = "DAP hover/eval", mode = { "n", "v" } },
    },
  },
}
