return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- Modern bottom popup — much cleaner than the legacy "classic" float.
      preset = "modern",

      -- How long to wait before the popup appears (ms). 200 feels snappy.
      delay = 200,

      -- Auto-expand groups that contain few items so you don't drill in.
      expand = 1,

      -- Predictable order: local mappings first, then by group, then alphanum.
      sort = { "local", "order", "group", "alphanum", "mod" },

      -- Disable noisy built-in popups that take over `'` and `"` keys.
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
        mappings = true,           -- automatic per-keymap icons via mini.icons / web-devicons
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },

      -- Declarative group spec: every leader namespace gets a name.
      -- This is the v3 API — replaces the old `register()` calls.
      spec = {
        { "<leader>b", group = "Buffer",          icon = "" },
        { "<leader>c", group = "Code / Copy",     icon = "" },
        { "<leader>d", group = "Debug",           icon = "" },
        { "<leader>f", group = "Find / Files",    icon = "" },
        { "<leader>g", group = "Git",             icon = "" },
        { "<leader>h", group = "Hunk (Git)",      icon = "" },
        { "<leader>j", group = "Jump (Harpoon)",  icon = "󰛢" },
        { "<leader>l", group = "LSP",             icon = "" },
        { "<leader>m", group = "Format",          icon = "" },
        { "<leader>r", group = "Refactor",        icon = "" },
        { "<leader>s", group = "Search / Replace", icon = "" },
        { "<leader>t", group = "Test",            icon = "󰙨" },
        { "<leader>u", group = "UI Toggles",       icon = "" },
        { "<leader>w", group = "Window / Wrap",   icon = "" },
        { "<leader>x", group = "Trouble",         icon = "" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show { global = false } end,
        desc = "Buffer-local keymaps (which-key)",
      },
      {
        "<leader>K",
        function() require("which-key").show { keys = "<leader>", loop = true } end,
        desc = "Browse all leader keymaps",
      },
    },
  },
}
