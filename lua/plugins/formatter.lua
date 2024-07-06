return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.erb_lint,
        null_ls.builtins.diagnostics.rubocop,
        null_ls.builtins.formatting.rubocop,
      },
    })

    -- Bind <leader>f to format the current buffer
    vim.api.nvim_set_keymap('n', '<leader>ft', ':lua vim.lsp.buf.format({ async = true })<CR>',
      { noremap = true, silent = true })
  end,
}
