-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   branch = "v3.x",
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "nvim-tree/nvim-web-devicons",
--     "MunifTanjim/nui.nvim",
--   },
--   config = function()
--     vim.keymap.set("n", "<leader>e", "<CMD>Neotree toggle right<CR>", {})
--     vim.keymap.set("n", "<leader>n", "<CMD>Neotree focus<CR>", {})
--     vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
--   end,
-- }

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
          require("window-picker").setup {
            hint = "floating-big-letter",
            selection_chars = "FJDKSLA;CMRUEIWOQP",
            show_prompt = true,
            prompt_message = "Pick window: ",
            filter_rules = {
              autoselect_one = true,
              include_current_win = false,
              include_unfocusable_windows = false,
              bo = {
                filetype = { "NvimTree", "neo-tree", "notify", "snacks_notif" },
                buftype = { "terminal" },
              },
            },
            highlights = {
              enabled = true,
              statusline = {
                focused = { fg = "#1e222a", bg = "#569cd6", bold = true },
                unfocused = { fg = "#1e222a", bg = "#d4d4d4", bold = true },
              },
              winbar = {
                focused = { fg = "#1e222a", bg = "#569cd6", bold = true },
                unfocused = { fg = "#1e222a", bg = "#d4d4d4", bold = true },
              },
            },
            picker_config = {
              handle_mouse_click = false,
              statusline_winbar_picker = { use_winbar = "never" },
              floating_big_letter = { font = "ansi-shadow" },
            },
          }
        end,
      },
    },
    event = { "VeryLazy" },
    config = function()
      local status, neotree = pcall(require, "neo-tree")
      if not status then
        vim.notify(
          "Failed to load neo-tree.nvim",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Neo-tree Error", icon = "❌" }
        )
        return
      end

      -- Custom highlights
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#1e222a" })
      vim.api.nvim_set_hl(0, "NeoTreeBorder", { fg = "#569cd6" })
      vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#569cd6" })
      vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = "#d4d4d4" })
      vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#d19a66" })
      vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = "#55ff55" })
      vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#ff5555" })

      neotree.setup {
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          icon = {
            folder_closed = "󰉋",
            folder_open = "󰝰",
            folder_empty = "󰉖",
            default = "󰈙",
          },
          git_status = {
            symbols = {
              added = "✚",
              modified = "✹",
              deleted = "✖",
              renamed = "➜",
              untracked = "★",
              ignored = "◌",
              unstaged = "✗",
              staged = "✓",
              conflict = "",
            },
          },
          diagnostics = {
            symbols = {
              error = " ",
              warning = " ",
              hint = "󰌵 ",
              info = " ",
            },
          },
        },
        window = {
          position = "right",
          width = 40,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<CR>"] = "open",
            ["o"] = "open_with_window_picker",
            ["S"] = "split_with_window_picker",
            ["s"] = "vsplit_with_window_picker",
            ["t"] = "open_tabnew",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["A"] = "add_directory",
            ["d"] = {
              "delete",
              config = {
                confirm = function(state)
                  local node = state.tree:get_node()
                  local path = node:get_path()
                  local msg = string.format("Delete %s [%s]? (y/N): ", node.type, vim.fn.fnamemodify(path, ":t"))
                  return vim.fn.input(msg) == "y"
                end,
              },
            },
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<leader>tm"] = {
              function(state)
                local node = state.tree:get_node()
                if node.type == "directory" or node.type == "file" then
                  local path = node:get_path()
                  if path:match "templates/" or path:match "%.djhtml$" or path:match "%.html$" then
                    vim.api.nvim_command("edit " .. vim.fn.fnameescape(path))
                    vim.bo.filetype = "htmldjango"
                  else
                    vim.notify(
                      "Not a Django template",
                      vim.log.levels.WARN,
                      { timeout = 1000, title = "Neo-tree", icon = "⚠️" }
                    )
                  end
                end
              end,
              desc = "Open as Django template",
            },
          },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = { ".git", "node_modules", "__pycache__", ".DS_Store", ".venv", "staticfiles" },
            never_show = { ".DS_Store", "*.pyc", "*.pyo", "*.log" },
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = true,
          },
          use_libuv_file_watcher = true,
          hijack_netrw_behavior = "open_default",
        },
        buffers = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = true,
          },
          group_empty_dirs = true,
          show_unloaded = true,
        },
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              vim.notify(
                "File opened: " .. vim.fn.fnamemodify(file_path, ":t"),
                vim.log.levels.INFO,
                { timeout = 500, title = "Neo-tree", icon = "📂" }
              )
              if file_path:match "%.html$" and (file_path:match "templates/" or file_path:match "%.djhtml$") then
                vim.bo.filetype = "htmldjango"
              end
              require("neo-tree.command").execute { action = "close" }
            end,
          },
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.bo.filetype = "neo-tree"
              vim.bo.buftype = "nofile"
              vim.wo.signcolumn = "no"
              vim.b.hlchunk_disabled = true
            end,
          },
        },
        sources = {
          "filesystem",
          "buffers",
          "git_status",
        },
        source_selector = {
          winbar = true,
          statusline = false,
          sources = {
            { source = "filesystem", display_name = "📁 Files" },
            { source = "buffers", display_name = "📄 Buffers" },
            { source = "git_status", display_name = "📌 Git" },
          },
        },
      }

      -- Keybindings
      vim.keymap.set("n", "<leader>e", "<CMD>Neotree toggle right<CR>", { desc = "Toggle Neo-tree", noremap = true })
      vim.keymap.set("n", "<leader>n", "<CMD>Neotree focus<CR>", { desc = "Focus Neo-tree", noremap = true })
      vim.keymap.set(
        "n",
        "<leader>bf",
        "<CMD>Neotree buffers reveal float<CR>",
        { desc = "Show buffers in Neo-tree", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>fs",
        "<CMD>Neotree filesystem reveal float<CR>",
        { desc = "Show filesystem in Neo-tree", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>dt",
        "<CMD>Neotree toggle reveal dir=./templates<CR>",
        { desc = "Show Django templates", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>dm",
        "<CMD>Neotree toggle reveal dir=./migrations<CR>",
        { desc = "Show Django migrations", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>da",
        "<CMD>Neotree toggle reveal dir=./<YOUR_APP_NAME><CR>",
        { desc = "Show Django app", noremap = true }
      )
      vim.keymap.set("n", "<leader>wp", function()
        require("window-picker").pick_window()
      end, { desc = "Pick window", noremap = true })

      -- Prevent hlchunk.nvim from processing neo-tree buffers
      vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("NeoTreeHlchunkExclude", { clear = true }),
        pattern = { "neo-tree", "" },
        callback = function()
          vim.b.hlchunk_disabled = true
        end,
      })
    end,
  },
}
