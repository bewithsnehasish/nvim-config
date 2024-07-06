
return {
  -- Other plugin configurations
  {
    "terrortylor/nvim-comment",
    event = "BufRead",
    config = function()
      require("nvim_comment").setup({
        -- Your custom configuration goes here
        -- Example configuration:
        marker_padding = true,
        comment_empty = false,
        create_mappings = true,
      })
    end,
  },
}
