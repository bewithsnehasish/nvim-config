return {
  "eandrju/cellular-automaton.nvim",
  keys = {
    { "<leader>yr", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it Rain" },
    { "<leader>yl", "<cmd>CellularAutomaton game_of_life<CR>", desc = "Game of Life" },
    { "<leader>ys", "<cmd>CellularAutomaton slide<CR>", desc = "Slide Animation" },
  },
  config = function()
    local ca = require "cellular-automaton"

    -- Register the custom 'slide' animation
    ca.register_animation {
      fps = 50,
      name = "slide",
      update = function(grid)
        for i = 1, #grid do
          local prev = grid[i][#grid[i]]
          for j = 1, #grid[i] do
            grid[i][j], prev = prev, grid[i][j]
          end
        end
        return true
      end,
    }

    -- You can add more custom animations here if desired
  end,
}
