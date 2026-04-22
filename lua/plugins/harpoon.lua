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

      -- Telescope integration: browse harpoon list in a Telescope picker
      local function harpoon_telescope()
        local conf = require("telescope.config").values
        local file_paths = {}
        for _, item in ipairs(harpoon:list().items) do
          table.insert(file_paths, item.value)
        end
        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table { results = file_paths },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      -- Mark / list
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,
        { desc = "Harpoon: mark file" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon: quick menu" })
      vim.keymap.set("n", "<leader>ht", harpoon_telescope,
        { desc = "Harpoon: telescope picker" })

      -- Jump to slot 1-4 with <leader>1..4 — instant, no searching needed
      for i = 1, 4 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end,
          { desc = "Harpoon: jump to file " .. i })
      end

      -- Cycle through harpooned files
      vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end,
        { desc = "Harpoon: prev file" })
      vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end,
        { desc = "Harpoon: next file" })
    end,
  },
}
