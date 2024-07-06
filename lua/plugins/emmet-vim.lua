return {
  "mattn/emmet-vim",
  config = function()
    -- Emmet settings for various file types
    vim.g.user_emmet_settings = {
      javascript = {
        extends = "html",
      },
      typescriptreact = {
        extends = "html",
      },
      javascriptreact = {
        extends = "html",
      },
      ejs = {
        extends = "html, javascript",
      },
    }

    -- Map <C-y>, to trigger Emmet expansion in insert mode
    vim.api.nvim_set_keymap('i', '<C-y>,', '<Plug>(emmet-expand-abbr)', {})

    -- Ensure .ejs files are set to the HTML filetype
    vim.cmd([[
      autocmd BufRead,BufNewFile *.ejs set filetype=html
    ]])
  end,
}
