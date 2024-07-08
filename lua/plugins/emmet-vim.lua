return {
  "mattn/emmet-vim",
  config = function()
    -- emmet settings for various file types
    vim.g.user_emmet_settings = {
      javascript = {
        extends = "html",
      },
      typescriptreact = {
        extends = "html, jsx",
      },
      javascriptreact = {
        extends = "html, jsx",
      },
      ejs = {
        extends = "html, javascript",
      },
      html = {
        extends = "html,jsx,javascriptreact,javascript"
      }
    }

    -- map <c-y>, to trigger emmet expansion in insert mode
    vim.api.nvim_set_keymap('i', '<c-y>,', '<plug>(emmet-expand-abbr)', {})

    -- ensure .ejs files are set to the html filetype
    vim.cmd([[
      autocmd bufread,bufnewfile *.ejs set filetype=html
    ]])

    -- ensure .jsx and .tsx files are set to the appropriate filetype
    vim.cmd([[
      autocmd bufread,bufnewfile *.jsx set filetype=javascriptreact
      autocmd bufread,bufnewfile *.tsx set filetype=typescriptreact
    ]])
  end,
}
