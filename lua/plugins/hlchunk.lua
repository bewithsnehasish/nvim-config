return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local status, hlchunk = pcall(require, "hlchunk")
      if not status then
        vim.notify(
          "Failed to load hlchunk.nvim",
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Hlchunk Error", icon = "❌" }
        )
        return
      end

      hlchunk.setup {
        chunk = {
          enable = true,
          use_treesitter = true,
          notify = false,
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
          },
          style = {
            { fg = "#569cd6" },
          },
          exclude_filetypes = {
            ["snacks_picker_list"] = true,
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        indent = {
          enable = true,
          use_treesitter = false, -- Disable Treesitter indent to prevent errors
          chars = {
            "│",
          },
          style = {
            { fg = "#2D3640" },
          },
          exclude_filetypes = {
            ["snacks_picker_list"] = true,
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        line_num = {
          enable = true,
          use_treesitter = true,
          style = "#569cd6",
          exclude_filetypes = {
            ["snacks_picker_list"] = true,
            terminal = true,
            help = true,
            [""] = true,
            nofile = true,
            prompt = true,
            quickfix = true,
          },
        },
        -- blank disabled: renders extmarks on every blank line in the file.
        -- In large files (hundreds of blank lines) this causes heavy scroll lag.
        blank = { enable = false },
      }
    end,
  },
}
