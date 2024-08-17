return {
  "shellRaining/hlchunk.nvim",
  event = { "UIEnter" },
  config = function()
    require("hlchunk").setup {
      chunk = {
        enable = true,
        use_treesitter = true,
        notify = false, -- set to false to disable notifications
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = ">",
        },
        style = {
          { fg = "#806d9c" },
        },
      },
      indent = {
        enable = true,
        use_treesitter = true,
        chars = {
          "│",
        },
        style = {
          { fg = "#2D3640" },
        },
      },
      line_num = {
        enable = true,
        use_treesitter = true,
        style = "#806d9c",
      },
      blank = {
        enable = true,
        chars = {
          "․",
        },
        style = {
          { fg = "#2D3640" },
        },
      },
    }
  end,
}
