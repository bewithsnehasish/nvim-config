return {
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    config = function()
      local execs = {
        { nil, "<M-1>", "Horizontal Terminal", "horizontal", 0.3 },
        { nil, "<M-2>", "Vertical Terminal", "vertical", 0.4 },
        { nil, "<M-3>", "Float Terminal", "float", nil },
      }

      local function get_buf_size()
        local cbuf = vim.api.nvim_get_current_buf()
        local bufinfo = vim.tbl_filter(function(buf)
          return buf.bufnr == cbuf
        end, vim.fn.getwininfo(vim.api.nvim_get_current_win()))[1]
        if bufinfo == nil then
          return { width = -1, height = -1 }
        end
        return { width = bufinfo.width, height = bufinfo.height }
      end

      local function get_dynamic_terminal_size(direction, size)
        size = size
        if direction ~= "float" and tostring(size):find(".", 1, true) then
          size = math.min(size, 1.0)
          local buf_sizes = get_buf_size()
          local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width
          return buf_size * size
        else
          return size
        end
      end

      local exec_toggle = function(opts)
        local Terminal = require("toggleterm.terminal").Terminal
        local term = Terminal:new { cmd = opts.cmd, count = opts.count, direction = opts.direction }
        term:toggle(opts.size, opts.direction)
      end

      local add_exec = function(opts)
        local binary = opts.cmd:match "(%S+)"
        if vim.fn.executable(binary) ~= 1 then
          vim.notify("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
          return
        end

        vim.keymap.set({ "n", "t" }, opts.keymap, function()
          exec_toggle { cmd = opts.cmd, count = opts.count, direction = opts.direction, size = opts.size() }
        end, { desc = opts.label, noremap = true, silent = true })
      end

      for i, exec in pairs(execs) do
        local direction = exec[4]

        local opts = {
          cmd = exec[1] or vim.o.shell,
          keymap = exec[2],
          label = exec[3],
          count = i + 100,
          direction = direction,
          size = function()
            return get_dynamic_terminal_size(direction, exec[5])
          end,
        }

        add_exec(opts)
      end

      require("toggleterm").setup {
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        direction = "float",
        close_on_exit = true, -- close the terminal window when the process exits
        shell = nil, -- change the default shell
        float_opts = {
          border = "rounded",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
        winbar = {
          enabled = true,
          name_formatter = function(term) --  term: Terminal
            return term.count
          end,
        },
      }
      vim.cmd [[
      augroup terminal_setup | au!
      autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i
      autocmd TermEnter * startinsert!
      augroup end
      ]]

      vim.api.nvim_create_autocmd({ "TermEnter" }, {
        pattern = { "*" },
        callback = function()
          vim.cmd "startinsert"
          _G.set_terminal_keymaps()
        end,
      })

      local opts = { noremap = true, silent = true }
      function _G.set_terminal_keymaps()
        vim.api.nvim_buf_set_keymap(0, "t", "<m-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-l>", [[<C-\><C-n><C-W>l]], opts)
      end
    end,
  },
}

-- return {
--   {
--     "akinsho/toggleterm.nvim",
--     version = "*", -- Always use latest version
--     event = "VeryLazy",
--     config = function()
--       local Terminal = require("toggleterm.terminal").Terminal
--       local execs = {
--         { nil, "<M-1>", "Horizontal", "horizontal", 0.3 },
--         { nil, "<M-2>", "Vertical", "vertical", 0.4 },
--         { nil, "<M-3>", "Floating", "float", nil },
--       }
--
--       -- Optimized size calculation [[2]][[7]]
--       local function get_terminal_size(direction, ratio)
--         local buf = vim.api.nvim_get_current_buf()
--         local win = vim.api.nvim_get_current_win()
--         local width, height = vim.opt.columns:get(), vim.opt.lines:get()
--         local curr_w, curr_h = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
--
--         if direction == "horizontal" then
--           return math.floor(curr_h * (ratio or 0.3))
--         elseif direction == "vertical" then
--           return math.floor(curr_w * (ratio or 0.4))
--         end
--         return 20 -- Default fallback
--       end
--
--       -- Unified terminal toggle handler [[3]][[6]]
--       local function create_terminal(opts)
--         local term = Terminal:new {
--           cmd = opts.cmd,
--           count = opts.count,
--           direction = opts.direction,
--           size = function()
--             return get_terminal_size(opts.direction, opts.ratio)
--           end,
--         }
--         return function()
--           term:toggle()
--           if opts.direction == "float" then
--             vim.cmd "startinsert" -- Better focus for floating [[9]]
--           end
--         end
--       end
--
--       -- Keymap setup with validation [[8]][[10]]
--       for i, exec in ipairs(execs) do
--         local binary = exec[1] or vim.o.shell
--         if vim.fn.executable(binary) == 1 then
--           local opts = {
--             cmd = binary,
--             keymap = exec[2],
--             label = exec[3],
--             count = i + 100,
--             direction = exec[4],
--             ratio = exec[5], -- For proportional sizing
--           }
--
--           vim.keymap.set({ "n", "t" }, opts.keymap, create_terminal(opts), {
--             desc = "Toggle " .. opts.label .. " Terminal",
--             noremap = true,
--             silent = true,
--           })
--         end
--       end
--
--       -- Modernized core config [[4]][[7]]
--       require("toggleterm").setup {
--         size = 20,
--         open_mapping = [[<c-\>]],
--         hide_numbers = true,
--         shade_terminals = true,
--         shading_factor = 3, -- Improved contrast
--         start_in_insert = true,
--         insert_mappings = true,
--         persist_size = true, -- Maintain consistent dimensions
--         direction = "float",
--         close_on_exit = true,
--         shell = vim.o.shell,
--         float_opts = {
--           border = "double", -- Enhanced visibility
--           winblend = 5, -- Slight transparency
--           highlights = {
--             border = "FloatBorder",
--             background = "Normal",
--           },
--         },
--         winbar = {
--           enabled = true,
--           name_formatter = function(term)
--             return "Term " .. term.count
--           end,
--         },
--       }
--
--       -- Optimized terminal hooks [[6]][[9]]
--       vim.api.nvim_create_autocmd({ "TermEnter" }, {
--         pattern = { "*" },
--         callback = function()
--           vim.cmd "startinsert"
--           _G.set_terminal_keymaps()
--         end,
--       })
--
--       -- Enhanced terminal navigation [[3]][[6]]
--       local opts = { noremap = true, silent = true }
--       function _G.set_terminal_keymaps()
--         vim.api.nvim_buf_set_keymap(0, "t", "<M-h>", [[<C-\><C-n><C-W>h]], opts)
--         vim.api.nvim_buf_set_keymap(0, "t", "<M-j>", [[<C-\><C-n><C-W>j]], opts)
--         vim.api.nvim_buf_set_keymap(0, "t", "<M-k>", [[<C-\><C-n><C-W>k]], opts)
--         vim.api.nvim_buf_set_keymap(0, "t", "<M-l>", [[<C-\><C-n><C-W>l]], opts)
--         -- Add scroll support [[7]]
--         vim.api.nvim_buf_set_keymap(0, "t", "<C-Up>", [[scrollLineUp]], opts)
--         vim.api.nvim_buf_set_keymap(0, "t", "<C-Down>", [[scrollLineDown]], opts)
--       end
--
--       -- Persistent terminal history [[2]]
--       vim.cmd [[
--       augroup TerminalHistory
--         autocmd!
--         autocmd TermClose * setlocal noreadonly
--       augroup END
--       ]]
--     end,
--   },
-- }
