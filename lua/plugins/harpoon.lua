return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Lazy-loaded on keypresses
    keys = (function()
      local keys = {
        {
          "<leader>ja",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon: add (mark) file",
        },
        {
          "<leader>jj",
          function()
            local harpoon = require "harpoon"
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon: quick menu",
        },
        {
          "<leader>jt",
          function()
            local harpoon = require "harpoon"
            local items = {}
            for i, item in ipairs(harpoon:list().items) do
              table.insert(items, { idx = i, text = item.value, file = item.value })
            end
            Snacks.picker.pick {
              source = "harpoon",
              title = "Harpoon",
              items = items,
              format = function(item)
                return {
                  { tostring(item.idx) .. ": ", "Number" },
                  { vim.fn.fnamemodify(item.file, ":t"), "String" },
                  { "  " .. vim.fn.fnamemodify(item.file, ":h"), "Comment" },
                }
              end,
              preview = "file",
              confirm = function(picker, item)
                picker:close()
                if item then
                  harpoon:list():select(item.idx)
                end
              end,
            }
          end,
          desc = "Harpoon: snacks picker (with preview)",
        },
        {
          "<leader>jp",
          function()
            require("harpoon"):list():prev()
          end,
          desc = "Harpoon: prev file",
        },
        {
          "<leader>jn",
          function()
            require("harpoon"):list():next()
          end,
          desc = "Harpoon: next file",
        },
      }
      for i = 1, 4 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon: jump to file " .. i,
        })
      end
      return keys
    end)(),
    config = function()
      local harpoon = require "harpoon"
      harpoon:setup {
        settings = {
          save_on_toggle = true, -- persist list when menu closes
          sync_on_ui_close = true,
        },
      }
    end,
  },
}
