return {
  -- Markdown support
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
    run = "cd app && npm install",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_auto_start = 1
      vim.cmd [[
        autocmd FileType markdown nnoremap <buffer> <Leader>pm :MarkdownPreviewToggle<CR>
        ]]
    end,
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
