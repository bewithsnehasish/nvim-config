return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- Windows needs cmake; Unix/Mac can use make.
        build = vim.fn.has "win32" == 1
            and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
          or "make",
      },
    },
    keys = {
      { "<leader>bb", "<cmd>Telescope buffers previewer=false<cr>", desc = "Find buffers" },
      { "<leader>fb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
      { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fp", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Projects" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last Search" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent File" },
    },
    config = function()
      local icons = require "user.icons"
      local actions = require "telescope.actions"

      require("telescope").setup {
        defaults = {
          prompt_prefix = icons.ui.Telescope .. " ",
          selection_caret = icons.ui.Forward .. " ",
          entry_prefix = "   ",
          initial_mode = "insert",
          selection_strategy = "reset",
          path_display = { "smart" },
          color_devicons = true,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!dist/",
            "--glob=!build/",
            "--glob=!.next/",
            "--glob=!.nuxt/",
            "--glob=!.cache/",
            "--glob=!vendor/",
            "--glob=!*.min.js",
            "--glob=!*.lock",
          },
          file_ignore_patterns = {
            "node_modules/",
            "%.git/",
            "dist/",
            "build/",
            "%.next/",
            "%.nuxt/",
            "%.cache/",
            "vendor/",
          },

          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["<esc>"] = actions.close,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          live_grep = { theme = "dropdown" },
          grep_string = { theme = "dropdown" },
          find_files = { theme = "dropdown", previewer = false },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
            mappings = {
              i = { ["<C-d>"] = actions.delete_buffer },
              n = { ["dd"] = actions.delete_buffer },
            },
          },
          planets = { show_pluto = true, show_moon = true },
          colorscheme = { enable_preview = true },
          lsp_references = { theme = "dropdown", initial_mode = "normal" },
          lsp_definitions = { theme = "dropdown", initial_mode = "normal" },
          lsp_declarations = { theme = "dropdown", initial_mode = "normal" },
          lsp_implementations = { theme = "dropdown", initial_mode = "normal" },
          lsp_type_definitions = { theme = "dropdown", initial_mode = "normal" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
      -- Guarded load: if fzf native wasn't compiled (e.g. cmake missing),
      -- telescope still works with the Lua sorter instead of crashing entirely.
      local fzf_ok, fzf_err = pcall(require("telescope").load_extension, "fzf")
      if not fzf_ok then
        vim.notify(
          "telescope-fzf-native not compiled — run :Lazy build telescope-fzf-native.nvim\n" .. tostring(fzf_err),
          vim.log.levels.WARN,
          { title = "Telescope", timeout = 5000 }
        )
      end
    end,
  },
}
