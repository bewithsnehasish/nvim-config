return {
  "brenoprata10/nvim-highlight-colors",
  config = function()
    -- Ensure termguicolors is enabled
    vim.opt.termguicolors = true

    require("nvim-highlight-colors").setup {
      -- Render style: 'background', 'foreground', or 'virtual'
      render = "background",

      -- Enable different color formats
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_ansi = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = true,

      -- Enable Tailwind CSS colors if you work with Tailwind
      enable_tailwind = false,

      -- Virtual text options (if you use render = 'virtual')
      virtual_symbol = "■",
      virtual_symbol_prefix = "",
      virtual_symbol_suffix = " ",
      virtual_symbol_position = "inline",

      -- Exclude large files for performance
      exclude_filetypes = {},
      exclude_buftypes = {},
      exclude_buffer = function(bufnr)
        -- Exclude files larger than 1MB
        local max_filesize = 1000000
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        return false
      end,
    }
  end,
}
