-- snacks.nvim picker — replaces Telescope.
-- Default layout is a wide floating window with preview, much more readable
-- than Telescope's "dropdown" theme used previously.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = {
        -- "default" = wide centered float with preview on the right.
        -- Override per-picker below for grep/references which benefit from "ivy" (bottom panel).
        layout = { preset = "default" },
        formatters = {
          file = { filename_first = false, truncate = 80 },
        },
        sources = {
          -- Code-context pickers: use ivy (full-width bottom panel) for readable previews
          grep            = { layout = { preset = "ivy", preview = "main" } },
          grep_word       = { layout = { preset = "ivy", preview = "main" } },
          lsp_references  = { layout = { preset = "ivy", preview = "main" } },
          lsp_definitions = { layout = { preset = "ivy", preview = "main" } },
          lsp_implementations = { layout = { preset = "ivy", preview = "main" } },
          lsp_type_definitions = { layout = { preset = "ivy", preview = "main" } },
          lsp_symbols     = { layout = { preset = "ivy", preview = "main" } },
          lsp_workspace_symbols = { layout = { preset = "ivy", preview = "main" } },
        },
        win = {
          input = {
            keys = {
              ["<C-j>"] = { "list_down", mode = { "i", "n" } },
              ["<C-k>"] = { "list_up",   mode = { "i", "n" } },
            },
          },
        },
        -- Match the ignore patterns from the previous Telescope config
        exclude = {
          "node_modules",
          ".git",
          "dist",
          "build",
          ".next",
          ".nuxt",
          ".cache",
          "vendor",
          "*.min.js",
          "*.lock",
          "*.csv",
          "*.tsv",
          "*.sql",
          "*.map",
          "*.svg",
          "*.png",
          "*.jpg",
          "*.jpeg",
          "*.gif",
          "*.ico",
          "*.woff",
          "*.woff2",
          "*.ttf",
        },
      },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
    keys = {
      -- Buffers / files
      { "<leader>bb", function() Snacks.picker.buffers() end,        desc = "Find buffers" },
      { "<leader>ff", function() Snacks.picker.files() end,          desc = "Find files" },
      { "<leader>fr", function() Snacks.picker.recent() end,         desc = "Recent files" },
      { "<leader>fg", function() Snacks.picker.grep() end,           desc = "Grep (live)" },
      { "<leader>fl", function() Snacks.picker.resume() end,         desc = "Resume last search" },
      { "<leader>fp", function() Snacks.picker.projects() end,       desc = "Projects" },

      -- Git
      { "<leader>fb", function() Snacks.picker.git_branches() end,   desc = "Git branches" },

      -- Misc
      { "<leader>fc", function() Snacks.picker.colorschemes() end,   desc = "Colorscheme" },
      { "<leader>fh", function() Snacks.picker.help() end,           desc = "Help tags" },
      { "<leader>fk", function() Snacks.picker.keymaps() end,        desc = "Keymaps" },
    },
  },
}
