return {
  -- Markdown support
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "org" },
    opts = {
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎰 ", "󰎳 " },
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
    },
  },
  {
    "plasticboy/vim-markdown",
    ft = { "markdown" },
    config = function() end,
  },
  {
    "vim-pandoc/vim-pandoc",
    ft = { "markdown" },
    config = function()
      vim.cmd [[
        autocmd FileType markdown nnoremap <buffer> <Leader>pp :Pandoc!<CR>
        ]]
    end,
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.cmd [[
        autocmd FileType markdown nnoremap <buffer> <Leader>tm :TableModeToggle<CR>
        ]]
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    -- Use the plugin's bundled installer — downloads pre-built Go binaries,
    -- doesn't mutate app/yarn.lock and so doesn't leave the repo dirty.
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
    end,
    keys = {
      { "<leader>pm", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown preview toggle" },
    },
  },

  -- Documentation and notes
  {
    "vimwiki/vimwiki",
    config = function()
      vim.g.vimwiki_list = {
        {
          path = "~/vimwiki/",
          syntax = "markdown",
          ext = ".md",
        },
      }
      vim.cmd [[
        nnoremap <Leader>ww :VimwikiIndex<CR>
        nnoremap <Leader>wt :VimwikiTabIndex<CR>
        nnoremap <Leader>ws :VimwikiUISelect<CR>
      ]]
    end,
  },
  {
    "kristijanhusak/orgmode.nvim",
    ft = { "org" },
    config = function()
      require("orgmode").setup {}
      vim.cmd [[
        nnoremap <Leader>oa :OrgCapture<CR>
        nnoremap <Leader>oi :OrgAgenda<CR>
      ]]
    end,
  },
}
