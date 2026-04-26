return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Load eagerly — keymaps need to work from any buffer immediately
    event = "VeryLazy",
    config = function()
      local harpoon = require "harpoon"
      harpoon:setup {
        settings = {
          save_on_toggle = true,   -- persist list when menu closes
          sync_on_ui_close = true,
        },
      }

      -- snacks.nvim picker: browse the harpoon list with file preview
      local function harpoon_picker()
        local items = {}
        for i, item in ipairs(harpoon:list().items) do
          table.insert(items, {
            idx = i,
            text = item.value,
            file = item.value,
          })
        end
        Snacks.picker.pick({
          source = "harpoon",
          title = "Harpoon",
          items = items,
          format = "file",
          preview = "file",
          confirm = function(picker, item)
            picker:close()
            if item then harpoon:list():select(item.idx) end
          end,
        })
      end

      -- Mark / list — namespaced under <leader>j ("jump") to avoid clashing
      -- with gitsigns' <leader>h* (hunk) keymaps.
      vim.keymap.set("n", "<leader>ja", function() harpoon:list():add() end,
        { desc = "Harpoon: add (mark) file" })
      vim.keymap.set("n", "<leader>jj", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon: quick menu" })
      vim.keymap.set("n", "<leader>jt", harpoon_picker,
        { desc = "Harpoon: snacks picker (with preview)" })

      -- Jump to slot 1-4 with <leader>1..4 — instant, no searching needed
      for i = 1, 4 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end,
          { desc = "Harpoon: jump to file " .. i })
      end

      -- Cycle through harpooned files
      vim.keymap.set("n", "<leader>jp", function() harpoon:list():prev() end,
        { desc = "Harpoon: prev file" })
      vim.keymap.set("n", "<leader>jn", function() harpoon:list():next() end,
        { desc = "Harpoon: next file" })
    end,
  },
}
