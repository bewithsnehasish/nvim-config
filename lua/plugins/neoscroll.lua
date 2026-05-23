return {
  "karb94/neoscroll.nvim",
  enabled = false,
}

-- Original config kept for history/revertability:
-- return {
--   "karb94/neoscroll.nvim",
--   config = function()
--     local neoscroll = require "neoscroll"
-- 
--     neoscroll.setup {
--       easing_function = "quadratic",
--       hide_cursor = true,
--     }
-- 
--     local mouse_maps = {
--       ["<ScrollWheelUp>"] = function()
--         neoscroll.scroll(-0.1, {
--           move_cursor = false,
--           duration = 120, -- lower = faster, higher = smoother
--         })
--       end,
-- 
--       ["<ScrollWheelDown>"] = function()
--         neoscroll.scroll(0.1, {
--           move_cursor = false,
--           duration = 120,
--         })
--       end,
--     }
-- 
--     local modes = { "n", "v", "x" }
--     for key, fn in pairs(mouse_maps) do
--       vim.keymap.set(modes, key, fn, { silent = true })
--     end
--   end,
-- }
