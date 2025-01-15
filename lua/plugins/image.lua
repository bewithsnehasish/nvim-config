return {
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = true,
      tmux_show_only_in_active_window = true,
      clear_on_leave = true,
      window_overlap_clear_enabled = true,

      -- GIF settings
      anime = {
        enabled = true, -- Enable animation support
        loop = true, -- Loop GIFs
        auto_play = true, -- Start playing automatically
        loop_cooldown = 0, -- No delay between loops
        frame_cooldown = 100, -- Delay between frames in milliseconds
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}