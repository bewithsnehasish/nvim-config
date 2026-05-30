-- snacks.nvim picker — replaces Telescope.
-- Default layout is a wide floating window with preview, much more readable
-- than Telescope's "dropdown" theme used previously.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      -- Terminal navigation mappings inside terminal buffers
      vim.keymap.set("t", "<M-h>", [[<C-\><C-n><C-w>h]], { silent = true, desc = "Navigate window left" })
      vim.keymap.set("t", "<M-j>", [[<C-\><C-n><C-w>j]], { silent = true, desc = "Navigate window down" })
      vim.keymap.set("t", "<M-k>", [[<C-\><C-n><C-w>k]], { silent = true, desc = "Navigate window up" })
      vim.keymap.set("t", "<M-l>", [[<C-\><C-n><C-w>l]], { silent = true, desc = "Navigate window right" })

      -- Set word highlighting colors (from old vim-illuminate setup)
      vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3E4452", underline = false })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#3E4452", underline = false })
    end,
    opts = {
      bigfile = {
        enabled = true,
        size = 500 * 1024, -- 500 KB (matching your previous LargeFilePerf threshold)
        setup = function(ctx)
          -- Custom large file disabling flags (from old options.lua autocommand)
          vim.b[ctx.buf].large_file = true
          vim.b[ctx.buf].hlchunk_disabled = true
          vim.b[ctx.buf].miniindentscope_disable = true
          vim.opt_local.spell = false
          vim.opt_local.swapfile = false
          vim.opt_local.undofile = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.colorcolumn = ""

          -- Standard Snacks bigfile optimizations
          if vim.fn.exists ":NoMatchParen" ~= 0 then
            vim.cmd [[NoMatchParen]]
          end
          Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
          vim.b.completion = false
          vim.b.minianimate_disable = true
          vim.b.minihipatterns_disable = true
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ctx.buf) then
              vim.bo[ctx.buf].syntax = ctx.ft
            end
          end)
        end,
      },
      quickfile = { enabled = true },
      scroll = { enabled = true }, -- smooth scrolling (replaces neoscroll)
      words = { enabled = true }, -- cursor word highlighting (replaces vim-illuminate)
      explorer = { replace_netrw = true }, -- file explorer (replaces neo-tree)
      dashboard = {
        enabled = true, -- startup dashboard (replaces alpha-nvim)
        preset = {
          header = (function()
            local logo = {
              [[                                              ]],
              [[       ████ ██████           █████      ██]],
              [[      ███████████             █████ ]],
              [[      █████████ ███████████████████ ███   ███████████]],
              [[     █████████  ███    █████████████ █████ ██████████████]],
              [[    █████████ ██████████ █████████ █████ █████ ████ █████]],
              [[  ███████████ ███    ███ █████████ █████ █████ ████ █████]],
              [[ ██████  █████████████████████ ████ █████ █████ ████ ██████]],
            }
            local max_w = 0
            for _, line in ipairs(logo) do
              local w = vim.api.nvim_strwidth(line)
              if w > max_w then
                max_w = w
              end
            end
            local padded = {}
            for _, line in ipairs(logo) do
              local w = vim.api.nvim_strwidth(line)
              local padding = string.rep(" ", max_w - w)
              table.insert(padded, line .. padding)
            end
            return table.concat(padded, "\n")
          end)(),
        },
      },
      picker = {
        -- "default" = wide centered float with preview on the right.
        -- Override per-picker below for grep/references which benefit from "ivy" (bottom panel).
        layout = { preset = "default" },
        formatters = {
          file = { filename_first = false, truncate = 80 },
        },
        sources = {
          -- Grep: ivy bottom panel, preview pane shows the matched file at the hit line
          grep = { layout = { preset = "ivy" } },
          grep_word = { layout = { preset = "ivy" } },

          -- File Explorer: open on the right (matches previous Neo-tree setup)
          explorer = {
            layout = { layout = { position = "right" } },
            ignored = true, -- Don't filter git-ignored files by default, so Shift+H reveals dotfiles like .env
          },

          -- LSP pickers: vertical split — top half = results list with file+line+code,
          -- bottom half = live preview of the file at the selected reference.
          -- "preview = main" was wrong: it replaced the preview with the editor window
          -- instead of showing the reference content alongside the results list.
          lsp_references = { layout = { preset = "vertical" } },
          lsp_definitions = { layout = { preset = "vertical" } },
          lsp_implementations = { layout = { preset = "vertical" } },
          lsp_type_definitions = { layout = { preset = "vertical" } },
          lsp_symbols = { layout = { preset = "vertical" } },
          lsp_workspace_symbols = { layout = { preset = "vertical" } },
        },
        win = {
          input = {
            keys = {
              ["<C-j>"] = { "list_down", mode = { "i", "n" } },
              ["<C-k>"] = { "list_up", mode = { "i", "n" } },
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
          -- "*.csv",
          "*.tsv",
          "*.sql",
          "*.map",
          -- "*.svg",
          -- "*.png",
          -- "*.jpg",
          -- "*.jpeg",
          -- "*.gif",
          "*.ico",
          "*.woff",
          "*.woff2",
          "*.ttf",
        },
      },
    },
    keys = {
      -- Buffers / files
      {
        "<leader>bb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer (layout safe)",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep (live)",
      },
      {
        "<leader>fl",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume last search",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },

      -- Git
      {
        "<leader>fb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git branches",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit { win = { border = "rounded", width = 0.9, height = 0.9 } }
        end,
        desc = "Lazygit",
      },
      {
        "<leader>gf",
        function()
          Snacks.lazygit.log_file { win = { border = "rounded", width = 0.9, height = 0.9 } }
        end,
        desc = "Lazygit Current File History",
      },
      {
        "<leader>gl",
        function()
          Snacks.lazygit.log { win = { border = "rounded", width = 0.9, height = 0.9 } }
        end,
        desc = "Lazygit Log (All)",
      },

      -- Terminals (replaces toggleterm)
      {
        "<M-1>",
        function()
          Snacks.terminal.toggle(nil, { count = 1, win = { position = "bottom", height = 0.3 } })
        end,
        desc = "Toggle Horizontal Terminal",
        mode = { "n", "t" },
      },
      {
        "<M-2>",
        function()
          Snacks.terminal.toggle(nil, { count = 2, win = { position = "right", width = 0.4 } })
        end,
        desc = "Toggle Vertical Terminal",
        mode = { "n", "t" },
      },
      {
        "<M-3>",
        function()
          Snacks.terminal.toggle(
            nil,
            { count = 3, win = { position = "float", border = "rounded", width = 0.85, height = 0.85 } }
          )
        end,
        desc = "Toggle Float Terminal",
        mode = { "n", "t" },
      },

      -- File Explorer (replaces neo-tree)
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "Toggle File Explorer",
      },
      {
        "<leader>n",
        function()
          Snacks.explorer()
        end,
        desc = "Focus File Explorer",
      },

      -- Words Reference Jump (replaces vim-illuminate)
      {
        "]r",
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = { "n", "t" },
      },
      {
        "[r",
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = { "n", "t" },
      },
      {
        "<leader>ui",
        function()
          Snacks.toggle.words():toggle()
        end,
        desc = "Toggle Reference Highlighting",
      },

      -- Misc
      {
        "<leader>fc",
        function()
          Snacks.picker.colorschemes()
        end,
        desc = "Colorscheme",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
    },
  },
}
