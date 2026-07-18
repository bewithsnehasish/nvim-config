return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 200,
      expand = 1,
      sort = { "local", "order", "group", "alphanum", "mod" },
      plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = false },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },

      win = {
        border = "rounded",
        padding = { 1, 2 },
      },

      icons = {
        mappings = true,
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },

      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find / Files" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunk (Git)" },
        { "<leader>j", group = "Jump (Harpoon)", icon = "󰛢" },
        { "<leader>l", group = "LSP" },
        { "<leader>m", group = "Format" },
        { "<leader>p", group = "Project" },
        { "<leader>r", group = "Refactor" },
        { "<leader>s", group = "Search" },
        { "<leader>t", group = "Test", icon = "󰙨" },
        { "<leader>u", group = "UI Toggles" },
        { "<leader>w", group = "Wiki / Wrap" },
        { "<leader>x", group = "Trouble" },
        { "<leader>y", group = "Fun" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer-local keymaps (which-key)",
      },
      {
        "<leader>k",
        function()
          require("which-key").show { keys = "<leader>", loop = true }
        end,
        desc = "Browse all leader keymaps",
      },
    },
  },
}
