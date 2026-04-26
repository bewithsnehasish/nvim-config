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
          -- Grep: ivy bottom panel, preview pane shows the matched file at the hit line
          grep      = { layout = { preset = "ivy" } },
          grep_word = { layout = { preset = "ivy" } },

          -- LSP pickers: vertical split — top half = results list with file+line+code,
          -- bottom half = live preview of the file at the selected reference.
          -- "preview = main" was wrong: it replaced the preview with the editor window
          -- instead of showing the reference content alongside the results list.
          lsp_references       = { layout = { preset = "vertical" } },
          lsp_definitions      = { layout = { preset = "vertical" } },
          lsp_implementations  = { layout = { preset = "vertical" } },
          lsp_type_definitions = { layout = { preset = "vertical" } },
          lsp_symbols          = { layout = { preset = "vertical" } },
          lsp_workspace_symbols = { layout = { preset = "vertical" } },
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
